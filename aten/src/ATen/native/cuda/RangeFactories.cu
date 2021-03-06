#include <ATen/Dispatch.h>
#include <ATen/NativeFunctions.h>
#include <ATen/AccumulateType.h>
#include <ATen/cuda/Exceptions.h>
#include <cmath>
#include <limits>

#include <thrust/device_ptr.h>
#include <thrust/sequence.h>

namespace at {
namespace native {

template<typename T, typename accT = T>
struct LinspaceOp {
  __host__ __device__ LinspaceOp(accT start, accT step):
    start_(start), step_(step) { }
  __device__ __forceinline__ T operator()(ptrdiff_t index) {
    accT increment = step_ * static_cast<accT>(index);
    accT value = start_ + increment;
    return static_cast<T>(value);
  }

  const accT start_, step_;
};

template<typename T, typename accT = T>
struct LogspaceOp {
  __host__ __device__ LogspaceOp(accT start, accT step):
    start_(start), step_(step) { }
  __device__ __forceinline__ T operator()(ptrdiff_t index) {
    accT increment = step_ * static_cast<accT>(index);
    accT base10 = 10;
    accT value = std::pow(base10, start_ + increment);
    return static_cast<T>(value);
  }

  const accT start_, step_;
};

Tensor& linspace_cuda_out(Tensor& result, Scalar start, Scalar end, int64_t steps) {
  AT_CHECK(steps >= 0, "number of steps must be non-negative");

  if (result.numel() != steps) {
    result.resize_({steps});
  }
  Tensor r = result.is_contiguous() ? result : result.contiguous();

  if (steps == 0) {
    // skip
  } else if (steps == 1) {
    r.fill_(start);
  } else {
    AT_DISPATCH_FLOATING_TYPES(r.type(), "linspace", [&]() {
      scalar_t scalar_start = start.to<scalar_t>();
      scalar_t scalar_end = end.to<scalar_t>();
      scalar_t step = (scalar_end - scalar_start) / static_cast<scalar_t>(steps - 1);
      LinspaceOp<scalar_t> linspace_method(scalar_start, step);
      thrust::device_ptr<scalar_t> data_(r.data<scalar_t>());
      thrust::tabulate(data_, data_ + steps, linspace_method);
    });
  }

  if (!result.is_contiguous()) {
    result.copy_(r);
  }
  AT_CUDA_CHECK(cudaGetLastError());
  return result;
}

Tensor& logspace_cuda_out(Tensor& result, Scalar start, Scalar end, int64_t steps) {
  AT_CHECK(steps >= 0, "number of steps must be non-negative");

  if (result.numel() != steps) {
    result.resize_({steps});
  }
  Tensor r = result.is_contiguous() ? result : result.contiguous();

  if (steps == 0) {
    // skip
  } else if (steps == 1) {
    r.fill_(std::pow(10.0, start.to<double>()));
  } else {
    AT_DISPATCH_FLOATING_TYPES(r.type(), "logspace", [&]() {
      scalar_t scalar_start = start.to<scalar_t>();
      scalar_t scalar_end = end.to<scalar_t>();
      scalar_t step = (scalar_end - scalar_start) / static_cast<scalar_t>(steps - 1);
      LogspaceOp<scalar_t> logspace_method(scalar_start, step);
      thrust::device_ptr<scalar_t> data_(r.data<scalar_t>());
      thrust::tabulate(data_, data_ + steps, logspace_method);
    });
  }

  if (!result.is_contiguous()) {
    result.copy_(r);
  }
  AT_CUDA_CHECK(cudaGetLastError());
  return result;
}

Tensor& range_cuda_out(Tensor& result, Scalar start, Scalar end, Scalar step) {
  AT_DISPATCH_ALL_TYPES_AND_HALF(result.type(), "range", [&]() {
    using accscalar_t = at::acc_type<scalar_t, true>;
    auto xstart = start.to<accscalar_t>();
    auto xend = end.to<accscalar_t>();
    auto xstep = step.to<accscalar_t>();

    AT_CHECK(xstep > 0 || xstep < 0, "step must be nonzero");
    AT_CHECK(std::isfinite(static_cast<double>(xstart)) &&
             std::isfinite(static_cast<double>(xend)),
             "unsupported range: ", xstart, " -> ", xend);
    AT_CHECK(((xstep > 0) && (xend >= xstart)) || ((xstep < 0) && (xend <= xstart)),
             "upper bound and larger bound inconsistent with step sign");
    int64_t size = static_cast<int64_t>(((xend - xstart) / xstep) + 1);
    if (result.numel() != size) {
      result.resize_({size});
    }
    Tensor r = result.is_contiguous() ? result : result.contiguous();
    LinspaceOp<scalar_t, accscalar_t> linspace_method(xstart, xstep);
    thrust::device_ptr<scalar_t> data_ptr(r.data<scalar_t>());
    thrust::tabulate(data_ptr, data_ptr + size, linspace_method);

    if (!result.is_contiguous()) {
      result.copy_(r);
    }
  });

  AT_CUDA_CHECK(cudaGetLastError());
  return result;
}

}} // namespace at::native
