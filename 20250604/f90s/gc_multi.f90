module constants_gc
  implicit none
  real(8), parameter :: pi = 3.141592653589793d0
  real(8), parameter :: mu0 = 4.d0 * pi * 1.d-7
  real(8), parameter :: q = -1.60217662d-19
  real(8), parameter :: m = 9.10938356d-31
  real(8), parameter :: Current = 2.00d5
  real(8), parameter :: epsilon = m / q
  integer, parameter :: steps = 10000
  real(8), parameter :: dt = 1.d-12
  real(8), parameter :: delta=1.d-8
  real(8), parameter :: x01 = 1.0d0
  real(8), parameter :: y01 = 0.0d0
  real(8), parameter :: z01 = 0.0d0
  real(8), parameter :: x02 = 0.0d0
  real(8), parameter :: y02 = 1.0d6
  real(8), parameter :: z02 = 1.0d6
  real(8), parameter :: scale=-2.021d-14
end module constants_gc

module magnetic_field_gc
  use constants_gc
  implicit none
contains
  subroutine Bfield(x, y, z, Bx, By, Bz)
    real(8), intent(in) :: x, y, z
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
    Btheta = mu0 * Current / (2.d0 * pi * r)

    Bx = -Btheta * y / r
    By =  Btheta * x / r
    Bz = 0.d0
  end subroutine Bfield
end module magnetic_field_gc

module unit_mag_gc
  use constants_gc
  use magnetic_field_gc
  implicit none
contains
  subroutine Unitmag(x, y, z, Bhx, Bhy, Bhz)
    real(8), intent(in) :: x, y, z
    real(8), intent(out) :: Bhx, Bhy, Bhz
    real(8) :: Bmag

    call Bfield(x, y, z, Bhx, Bhy, Bhz)
    Bmag = sqrt(Bhx**2 + Bhy**2 + Bhz**2)
    if (Bmag == 0.d0) then
      Bhx = 0.d0
      Bhy = 0.d0
      Bhz = 0.d0
      return
    end if
    Bhx = Bhx / Bmag
    Bhy = Bhy / Bmag
    Bhz = Bhz / Bmag
  end subroutine Unitmag
end module unit_mag_gc

module abs_b_gc
  use constants_gc
  use magnetic_field_gc
  implicit none
contains
  subroutine Absb(x, y, z, B)
    real(8), intent(in) :: x, y, z
    real(8), intent(out) :: B
    real(8) :: Bhx, Bhy, Bhz

    call Bfield(x, y, z, Bhx, Bhy, Bhz)
    B = sqrt(Bhx**2 + Bhy**2 + Bhz**2)
  end subroutine Absb
end module abs_b_gc

module curl_operator_gc
  use unit_mag_gc
  implicit none
contains
  subroutine curlB(x, y, z, dx, dy, dz, cx, cy, cz)
    real(8), intent(in) :: x, y, z, dx, dy, dz
    real(8), intent(out) :: cx, cy, cz
    real(8) :: bx1, by1, bz1, bx2, by2, bz2

    call Unitmag(x, y + dy, z, bx1, by1, bz1)
    call Unitmag(x, y - dy, z, bx2, by2, bz2)
    cx = (bz1 - bz2) / (2.0 * dy)
    call Unitmag(x, y, z + dz, bx1, by1, bz1)
    call Unitmag(x, y, z - dz, bx2, by2, bz2)
    cx = cx - (by1 - by2) / (2.0 * dz)

    call Unitmag(x, y, z + dz, bx1, by1, bz1)
    call Unitmag(x, y, z - dz, bx2, by2, bz2)
    cy = (bx1 - bx2) / (2.0 * dz)
    call Unitmag(x + dx, y, z, bx1, by1, bz1)
    call Unitmag(x - dx, y, z, bx2, by2, bz2)
    cy = cy - (bz1 - bz2) / (2.0 * dx)

    call Unitmag(x + dx, y, z, bx1, by1, bz1)
    call Unitmag(x - dx, y, z, bx2, by2, bz2)
    cz = (by1 - by2) / (2.0 * dx)
    call Unitmag(x, y + dy, z, bx1, by1, bz1)
    call Unitmag(x, y - dy, z, bx2, by2, bz2)
    cz = cz - (bx1 - bx2) / (2.0 * dy)
  end subroutine curlB
end module curl_operator_gc

module cross_product_gc
  implicit none
contains
  subroutine Crossprod(a, b, c)
    real(8), dimension(3), intent(in) :: a, b
    real(8), dimension(3), intent(out) :: c

    c(1) = a(2) * b(3) - a(3) * b(2)
    c(2) = a(3) * b(1) - a(1) * b(3)
    c(3) = a(1) * b(2) - a(2) * b(1)
  end subroutine Crossprod
end module cross_product_gc

module gradb_gc
  use constants_gc
  use abs_b_gc
  implicit none
contains
  subroutine gradB(x, y, z, dx, dy, dz, Bx, By, Bz)
    real(8), value :: x, y, z, dx, dy, dz
    real(8), intent(out) :: Bx, By, Bz
    real(8) :: Bxu, Bxd, Byu, Byd, Bzu, Bzd

    call Absb(x+dx, y, z, Bxu)
    call Absb(x-dx, y, z, Bxd)
    call Absb(x, y+dy, z, Byu)
    call Absb(x, y-dy, z, Byd)
    call Absb(x, y, z+dz, Bzu)
    call Absb(x, y, z-dz, Bzd)
    Bx=(Bxu-Bxd)/(2.0*dx)
    By=(Byu-Byd)/(2.0*dy)
    Bz=(Bzu-Bzd)/(2.0*dz)
  end subroutine gradB
end module gradb_gc

module guiding_center_gc
  use constants_gc
  use magnetic_field_gc
  use cross_product_gc

  use curl_operator_gc
  use gradb_gc
  implicit none
contains
  subroutine compute_gc_velocity(X, u, vgc)
    real(8), dimension(3), intent(in) :: X
    real(8), intent(in) :: u
    real(8), dimension(3), intent(out) :: vgc
    real(8), dimension(3) :: Bvec, exb, Enorth, Bnorth, bhat
    real(8) :: Bx, By, Bz, Bhx, Bhy, Bhz, Bmag, Bnpara
    real(8) :: gBx, gBy, gBz

    call Bfield(X(1), X(2), X(3), Bx, By, Bz)
    Bvec = (/Bx, By, Bz/)
    Bmag = sqrt(Bx**2 + By**2 + Bz**2)
    if (Bmag == 0.d0) then
      vgc = 0.d0
      return
    end if

    bhat = Bvec / Bmag
    call curlB(X(1), X(2), X(3), delta, delta, delta, Bhx, Bhy, Bhz)
    Bnorth = Bvec + (/Bhx, Bhy, Bhz/)
    Bnpara = dot_product(Bnorth, bhat)
    call gradB(X(1), X(2), X(3), delta, delta, delta, gBx, gBy, gBz)
    Enorth = (/gBx, gBy, gBz/) * Bmag / epsilon

    if (Bnpara == 0.d0) then
      vgc = 0.d0
      return
    end if
    call Crossprod(Enorth, Bvec, exb)
    vgc = (u / Bnpara) * Bnorth + exb / (Bnpara * Bmag)
  end subroutine compute_gc_velocity

  subroutine rk4_step_gc(X, u, dt, amu)
    real(8), dimension(3), intent(inout) :: X
    real(8), intent(inout) :: u
    real(8), intent(in) :: dt, amu
    real(8), dimension(3) :: k1X, k2X, k3X, k4X, Xt, dotX, B
    real(8) :: Bmag

    call compute_gc_velocity(X, u, k1X)
    Xt = X + 0.5d0 * dt * k1X
    call compute_gc_velocity(Xt, u, k2X)
    Xt = X + 0.5d0 * dt * k2X
    call compute_gc_velocity(Xt, u, k3X)
    Xt = X + dt * k3X
    call compute_gc_velocity(Xt, u, k4X)

    dotX = (k1X + 2.d0*k2X + 2.d0*k3X + k4X) / 6.d0
    X = X + dt * dotX
    call Bfield(X(1), X(2), X(3), B(1), B(2), B(3))
    Bmag = sqrt(B(1)**2 + B(2)**2 + B(3)**2)
    if (Bmag > 0.d0) then
      u = dot_product(dotX, B) / Bmag
    else
      u = 0.d0
    end if
  end subroutine rk4_step_gc
end module guiding_center_gc

program main
  use constants_gc
  use magnetic_field_gc
  use guiding_center_gc
  use unit_mag_gc
  implicit none

  integer, parameter :: N_total = 900
  real(8), dimension(3) :: x0, v0, B, v_cross_B, X, b0, vperp
  real(8) :: amu, Bmag2, u
  real(8) :: vz_adjusted
  integer :: istep, i
  character(len=100) :: filename
  real(8) :: t_start, t_end, t_elapsed
  call cpu_time(t_start)
  open(unit=10, file="gc_final_positions.dat", status='replace', action='write', form='formatted')

  do i = 1, N_total
    ! 초기 조건 설정
    vz_adjusted = z02 - 1000.d0 * dble(i - 1)
    x0 = (/x01, y01, z01/)
    v0 = (/x02, y02, vz_adjusted/)

    call Unitmag(x0(1), x0(2), x0(3), b0(1), b0(2), b0(3))
    vperp = v0 - b0 * dot_product(b0, v0)
    amu = 0.5d0 * m * sum(vperp**2) / (q * sqrt(sum(b0**2)))

    call Bfield(x0(1), x0(2), x0(3), B(1), B(2), B(3))
    Bmag2 = sum(B**2)
    v_cross_B = (/vperp(2)*B(3)-vperp(3)*B(2), vperp(3)*B(1)-vperp(1)*B(3), vperp(1)*B(2)-vperp(2)*B(1)/)
    X = x0 + (m / (q * Bmag2)) * v_cross_B
    u = dot_product(v0, B) / sqrt(Bmag2)

    do istep = 1, steps
      call rk4_step_gc(X, u, dt, amu)
    end do

    ! 결과 기록: 입자 번호, 최종 x, y, z
    write(10,'(I5,3(1X,E16.8E3))') i, X(1), X(2), scale * X(3)
  end do

  close(10)
  call cpu_time(t_end)
  t_elapsed = t_end - t_start
  print *, "Elapsed CPU time (seconds):", t_elapsed
end program main

