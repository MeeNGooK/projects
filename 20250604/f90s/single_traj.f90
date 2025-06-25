module constants
  implicit none
  real(8), parameter :: pi = 3.141592653589793d0  ! 원주율
  real(8), parameter :: mu0 = 4.d0 * pi * 1.d-7   ! ｍｕ０
  real(8), parameter :: q   = -1.60217662d-19     ! 전하
  real(8), parameter :: m   = 9.10938356d-31      ! 전자 질량
  real(8), parameter :: I   = 2.00d5              ! 전류 (A)
  integer, parameter :: steps = 100000
  real(8), parameter :: dt = 1.d-12
  real(8), parameter :: x01 = 1.0d0   ! 초기 x좌표
  real(8), parameter :: y01 = 0.0d0   ! 초기 y 좌표
  real(8), parameter :: z01 = 0.0d0   ! 초기 z 좌표
  real(8), parameter :: x02 = 0.0d0   ! 초기 x 속도
  real(8), parameter :: y02 = 1.0d5   ! 초기 y 속도
  real(8), parameter :: z02 = 1.0d5   ! 초기 z 속도
end module constants

module magnetic_field
  use constants
  implicit none
contains
  subroutine Bfield(x, y, z, Bx, By, Bz)
    real(8), intent(in)  :: x, y, z
    real(8), intent(out) :: Bx, By, Bz
    real(8) :: r2, r, Btheta

    r2 = x*x + y*y
    if (r2 == 0.d0) then
      Bx = 0.d0
      By = 0.d0
      Bz = 0.d0
      return
    end if

    r = sqrt(r2)
    Btheta = mu0 * I / (2.d0 * pi * r)

    Bx = -Btheta * y / r
    By =  Btheta * x / r
    Bz = 0.d0
  end subroutine Bfield
end module magnetic_field

module deriv
  use constants
  use magnetic_field
  implicit none
contains
  subroutine compute_deriv(r, v, drdt, dvdt)
    real(8), dimension(3), intent(in)  :: r, v
    real(8), dimension(3), intent(out) :: drdt, dvdt
    real(8) :: Bx, By, Bz

    call Bfield(r(1), r(2), r(3), Bx, By, Bz)

    drdt = v
    dvdt(1) = (q/m)*(v(2)*Bz - v(3)*By)
    dvdt(2) = (q/m)*(v(3)*Bx - v(1)*Bz)
    dvdt(3) = (q/m)*(v(1)*By - v(2)*Bx)
  end subroutine compute_deriv
end module deriv

module rk4
  use constants
  use deriv
  implicit none
contains
  subroutine rk4_step(r, v, dt)
    real(8), dimension(3), intent(inout) :: r, v
    real(8), intent(in) :: dt
    real(8), dimension(3) :: k1r, k2r, k3r, k4r
    real(8), dimension(3) :: k1v, k2v, k3v, k4v
    real(8), dimension(3) :: rt, vt

    call compute_deriv(r, v, k1r, k1v)

    rt = r + 0.5d0 * dt * k1r
    vt = v + 0.5d0 * dt * k1v
    call compute_deriv(rt, vt, k2r, k2v)

    rt = r + 0.5d0 * dt * k2r
    vt = v + 0.5d0 * dt * k2v
    call compute_deriv(rt, vt, k3r, k3v)

    rt = r + dt * k3r
    vt = v + dt * k3v
    call compute_deriv(rt, vt, k4r, k4v)

    r = r + dt/6.d0*(k1r + 2.d0*k2r + 2.d0*k3r + k4r)
    v = v + dt/6.d0*(k1v + 2.d0*k2v + 2.d0*k3v + k4v)
  end subroutine rk4_step
end module rk4

program main
  use constants
  use rk4
  implicit none

  real(8), dimension(3) :: r, v
  real(8) :: t
  integer :: istep
  character(len=100) :: filename
  filename = "single_traj.dat"

  open(unit=10, file=filename, status='replace', action='write', form='formatted')

  r = (/x01, y01, z01/)  ! 초기 위치
  v = (/x02, y02, z02/)  ! 초기 속도

  do istep = 0, steps
    t = istep * dt
    write(10, '(F12.6, 3(1x, E16.8E3))') t, r(1), r(2), r(3)
    call rk4_step(r, v, dt)
  end do

  close(10)
end program main
