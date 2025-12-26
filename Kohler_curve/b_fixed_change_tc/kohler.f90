!kohler curve
!p=1010hPa, T=40℃〜80℃の条件下でのKohler curveを計算
!bを固定して、Tを変化させる
program kohler_curve
implicit none
            !########## Set value ##########
integer ::                     i, j
real ::                        start_time, finish_time ! for counting Cpu_time.
double precision, parameter :: dr   = 0.001d-6, &
                               rmax = 10d-6 ! 10 micro meter
integer, parameter          :: nr   = int(rmax / dr)
            !########## Parameter ########## 
double precision, parameter :: pi   = 3.14159265d0
! T, Tc, sigma are variables now
double precision            :: T, Tc, sigma
double precision, parameter :: T0   = 273.15d0  ! [K] 
double precision, parameter :: Rhow = 9.97d2 ! [kg/m^3] dnsity of water(p.2)
double precision, parameter :: Rv   = 461.51d0 ! gas constant [J/kg/K](water vapor)

            !########## Variable ########## 
double precision :: s, r, a, b, s_max, r_crit
character(len=50) :: filename

            !########## Calculation ########## 
b = 9.8075380110759942d-25

call cpu_time(start_time)

! Loop for Temperature: 313.15(40C) to 353.15(80C) step 10
do j = 0, 4
    T = 313.15d0 + dble(j) * 10.0d0
    Tc = T - T0
    sigma = 76.10d0 - 0.155d0 * Tc
    a = (2 * sigma * 1.0d-3) / (Rv * Rhow * T)
    
    ! Reset variables
    s = 0.0d0 
    r = 0.032d-6 ! Start
    s_max = 0.0d0
    r_crit = 0.0d0

    ! Generate filename
    write(filename, '("kohler_", I0, "C.dat")') nint(Tc)
    print *, "Calculating for Tc =", Tc, "(℃)"

    open(unit = 10, file = trim(filename), status = "replace", action = "write")
    
    do i = 0, nr
        r = r + dr
        
        if (s > s_max) then
            s_max = s
            r_crit = r
        end if
    
        s = 1.0d0 + a/r - b/(r**3) 
        
        write(10,'(F16.5,1X,F14.4)') r * 1.0d6, s * 100.0d0
    end do
    close(10)
    
    print *, "a : ", a
    print *, "b : ", b
    print *, "Tc : ", Tc, "[℃]"
    print *, "analytical r_crit (um) : ", ( (3.0d0 * b) / a )**(1.0d0/2.0d0) * 1.0d6
    print *, "numerical r_crit (um)  : ", r_crit * 1.0d6 
    print *, "difference r_crit (um) : ", (( (3.0d0 * b) / a )**(1.0d0/2.0d0) * 1.0d6) - (r_crit * 1.0d6)
    print *, "analytical s_crit (%)  : ", (( (4.0d0 * a**3) / (27.0d0 * b) )**(1.0d0/2.0d0)) * 100.0d0
    print *, "numerical s_crit (%)   : ", (s_max - 1.0d0) * 100.0d0
    print *, "difference s_crit      : ", ((( (4.0d0 * a**3) / (27.0d0 * b) )**(1.0d0/2.0d0)) * 100.0d0) - ((s_max - 1.0d0) * 100.0d0)
    print *, "------------------------------------------------"
end do

call cpu_time(finish_time)
print*,"Total execution time (seconds): ",finish_time - start_time

end program kohler_curve