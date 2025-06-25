module eqdsk_reader
  implicit none
  private
  public :: read_eqdsk, eqdsk_data

  type :: eqdsk_data
    integer :: nw, nh
    real(8) :: rleft, zmid, rdim, zdim
    real(8) :: rmaxis, zmaxis, psiaxis, psibdry
    real(8) :: bcentr, current, simag, sibry, rgrid1, zgrid1
    real(8), allocatable :: psi(:,:), fpol(:), ffprime(:), pprime(:), qpsi(:)
  end type eqdsk_data

contains

  subroutine read_eqdsk(filename, eq)
    character(len=*), intent(in) :: filename
    type(eqdsk_data), intent(out) :: eq

    character(len=256) :: line
    character(len=16) :: field
    character(len=256) :: last_words(20)
    integer :: nw_read, nh_read, nw_pos, nh_pos
    real(8), allocatable :: buffer(:)
    integer :: i, j, k, ios, unit, nvals, nwords

    open(newunit=unit, file=filename, status='old', iostat=ios)
    if (ios /= 0) stop 'Failed to open EQDSK file.'

    read(unit,'(A)', iostat=ios) line
    if (ios /= 0) stop 'Failed to read header line.'

    ! Attempt to parse last two words in the line
    nwords = 0
    do i = len_trim(line), 1, -1
      if (line(i:i) == ' ') then
        if (i < len_trim(line)) then
          nwords = nwords + 1
          read(line(i+1:len_trim(line)), *, iostat=ios) last_words(nwords)
          if (nwords == 2) exit
        end if
        line = line(:i-1)
      end if
    end do

    read(last_words(2), *, iostat=ios) eq%nh
    if (ios /= 0) stop 'Failed to parse nh'
    read(last_words(1), *, iostat=ios) eq%nw
    if (ios /= 0) stop 'Failed to parse nw'

    nvals = 15 + eq%nw * eq%nh + 5 * eq%nw
    allocate(buffer(nvals))

    k = 1
    do
      read(unit, '(A)', iostat=ios) line
      if (ios /= 0) exit
      do i = 1, len_trim(line)/16
        field = line((i-1)*16+1:i*16)
        read(field,*, iostat=ios) buffer(k)
        if (ios == 0) then
          k = k + 1
          if (k > nvals) exit
        end if
      end do
      if (k > nvals) exit
    end do
    close(unit)

    if (k <= nvals) then
      print *, 'ERROR: Only read', k-1, 'of', nvals, 'values'
      stop 'File is incomplete or corrupted'
    end if

    eq%rleft   = buffer(1)
    eq%zmid    = buffer(2)
    eq%rdim    = buffer(3)
    eq%zdim    = buffer(4)
    eq%rmaxis  = buffer(5)
    eq%zmaxis  = buffer(6)
    eq%psiaxis = buffer(7)
    eq%psibdry = buffer(8)
    eq%bcentr  = buffer(9)
    eq%current = buffer(10)
    eq%simag   = buffer(11)
    eq%sibry   = buffer(12)
    eq%rgrid1  = buffer(13)
    eq%zgrid1  = buffer(14)

    allocate(eq%psi(eq%nw, eq%nh))
    k = 16
    do j = 1, eq%nh
      do i = 1, eq%nw
        eq%psi(i,j) = buffer(k)
        k = k + 1
      end do
    end do

    allocate(eq%fpol(eq%nw), eq%ffprime(eq%nw), eq%pprime(eq%nw), eq%qpsi(eq%nw))
    eq%fpol    = buffer(k:k+eq%nw-1); k = k + eq%nw
    eq%ffprime = buffer(k:k+eq%nw-1); k = k + eq%nw
    eq%pprime  = buffer(k:k+eq%nw-1); k = k + eq%nw
    eq%qpsi    = buffer(k:k+eq%nw-1)
  end subroutine read_eqdsk

end module eqdsk_reader