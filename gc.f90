program gc
  implicit none

  ! 상수 정의(Constants)
  integer :: n, m
  real, dimension(:,:), allocatable :: a, b, c
  real :: m_e = 9.10938356e-31  ! 전자 질량(Electron mass)
  real :: q_e= 1.602176634e-19  ! 전자 전하(Electron charge)
  
  n = 10
  m = 10
  a = reshape([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0], [n,m])
  b = reshape([10.0, 9.0, 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0], [n,m])

  ! Perform matrix multiplication
  c = matmul(a,b)

end program gc