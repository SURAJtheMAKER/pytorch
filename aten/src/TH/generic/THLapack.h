#ifndef TH_GENERIC_FILE
#define TH_GENERIC_FILE "TH/generic/THLapack.h"
#else

/* Solve a triangular system of the form A * X = B  or A^T * X = B */
TH_API void THLapack_(trtrs)(char uplo, char trans, char diag, int n, int nrhs, scalar_t *a, int lda, scalar_t *b, int ldb, int* info);
/* ||AX-B|| */
TH_API void THLapack_(gels)(char trans, int m, int n, int nrhs, scalar_t *a, int lda, scalar_t *b, int ldb, scalar_t *work, int lwork, int *info);
/* Eigenvals */
TH_API void THLapack_(syev)(char jobz, char uplo, int n, scalar_t *a, int lda, scalar_t *w, scalar_t *work, int lwork, int *info);
/* Non-sym eigenvals */
TH_API void THLapack_(geev)(char jobvl, char jobvr, int n, scalar_t *a, int lda, scalar_t *wr, scalar_t *wi, scalar_t* vl, int ldvl, scalar_t *vr, int ldvr, scalar_t *work, int lwork, int *info);
/* svd */
TH_API void THLapack_(gesdd)(char jobz, int m, int n, scalar_t *a, int lda, scalar_t *s, scalar_t *u, int ldu, scalar_t *vt, int ldvt, scalar_t *work, int lwork, int *iwork, int *info);
/* LU decomposition */
TH_API void THLapack_(getrf)(int m, int n, scalar_t *a, int lda, int *ipiv, int *info);
TH_API void THLapack_(getrs)(char trans, int n, int nrhs, scalar_t *a, int lda, int *ipiv, scalar_t *b, int ldb, int *info);
/* Matrix Inverse */
TH_API void THLapack_(getri)(int n, scalar_t *a, int lda, int *ipiv, scalar_t *work, int lwork, int* info);

/* Positive Definite matrices */
/* Cholesky factorization */
TH_API void THLapack_(potrf)(char uplo, int n, scalar_t *a, int lda, int *info);
/* Matrix inverse based on Cholesky factorization */
TH_API void THLapack_(potri)(char uplo, int n, scalar_t *a, int lda, int *info);
/* Solve A*X = B with a symmetric positive definite matrix A using the Cholesky factorization */
TH_API void THLapack_(potrs)(char uplo, int n, int nrhs, scalar_t *a, int lda, scalar_t *b, int ldb, int *info);
/* Cholesky factorization with complete pivoting. */
TH_API void THLapack_(pstrf)(char uplo, int n, scalar_t *a, int lda, int *piv, int *rank, scalar_t tol, scalar_t *work, int *info);

/* QR decomposition */
TH_API void THLapack_(geqrf)(int m, int n, scalar_t *a, int lda, scalar_t *tau, scalar_t *work, int lwork, int *info);
/* Build Q from output of geqrf */
TH_API void THLapack_(orgqr)(int m, int n, int k, scalar_t *a, int lda, scalar_t *tau, scalar_t *work, int lwork, int *info);
/* Multiply Q with a matrix from output of geqrf */
TH_API void THLapack_(ormqr)(char side, char trans, int m, int n, int k, scalar_t *a, int lda, scalar_t *tau, scalar_t *c, int ldc, scalar_t *work, int lwork, int *info);

#endif
