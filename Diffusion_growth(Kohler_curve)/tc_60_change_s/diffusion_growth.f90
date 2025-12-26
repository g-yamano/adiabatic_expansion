program diffusion_growth
implicit none
            !########## Set value ##########
integer(8) ::                  i
real ::                        start_time, finish_time ! for counting Cpu_time.
double precision, parameter :: dt   = 1.0d-8, &
                               tmax = 0.3d0 
integer(8), parameter       :: nt   = nint(tmax / dt, 8)
            !########## Parameter ##########
double precision, parameter :: pi   = 3.14159265d0
double precision, parameter :: T    = 333.15d0  ! [K]　周囲温度
double precision, parameter :: T0   = 273.15d0  ! [K] 
double precision, parameter :: Tc   = T - T0  ! [℃]
double precision, parameter :: p    = 1010.0d0  ! [hPa]
double precision, parameter :: p0   = 1013.25d0 ! [hPa]
double precision, parameter :: Rhow = 9.97d2 ! [kg/m^3] dnsity of water(p.2)
double precision, parameter :: Rv   = 461.51d0 ! gas constant [J/kg/K]
double precision, parameter :: cal  = 4.1868d0 ! [J]
double precision, parameter :: sigma = 76.10d0 - 0.155d0 * Tc ![dyn/cm] = [mN/m]
!double precision, parameter :: vhf  = 1.867d0 ! van't hoff factor
!double precision, parameter :: mv   = 18.016d0 ! water molecular weight 
!double precision, parameter :: M    = 1.0d-14 ! mass of solute [g]
!double precision, parameter :: ms   = 58.44d0 ! solute molecular weight [g/mol] (NaCl)
double precision, parameter :: Kd   = (5.69d0 + 0.0168d0 * Tc) * 1.0d-5 * cal * 1.0d2 ! [cal/cm*s*℃] -> [J/(m * s * ℃)]
!double precision, parameter :: Kv = (3.73d0 + 0.020d0 * Tc) * 1.0d-5, & ! [cal/(cm * s * ℃)] (p.57) 
double precision, parameter :: Ka   = Kd
!double precision, parameter :: Ka = Kd * (1.0d0-(1.17d0 - 1.02d0 * Kv / Kd) * Rhov / Rhoa), & ! (p.57)  
double precision, parameter :: Le   = (597.3d0 - 0.561d0 * Tc) * cal * 1.0d3  ! [J/kg]
double precision, parameter :: es   = exp(19.482 - 4303.4/(Tc + 243.5)) ! [hPa]
double precision, parameter :: Dv   = 0.211d0 * ((T / T0) ** 1.94d0) * (p0 / p) ![cm^2/s] (p.55)
! 1[J] = 1[Pa*m^3]

            !########## Variable ##########
double precision            :: r_new, r, a, b, Fk, Fd, Kohler
double precision            :: S
double precision, dimension(9) :: S_list = (/ 0.99d0, 1.00d0, 1.005d0, 1.01d0, 1.011d0, 1.015d0, 1.02d0, 1.05d0, 1.10d0 /)
integer                     :: j
character(len=50)           :: filename

            !########## Calculation ########## 

a  = (2 * sigma * 1.0d-3) / (Rv * Rhow * T)
!b  = (3 * vhf * mv * M * 1.0d-3) / (4 * pi * Rhow * ms)
b  = 9.8075380110759942d-25
Fk = (Le / ( Rv * T ) - 1.0e0) * ( Le * Rhow ) / (Ka * T) ![s/m^2]
Fd = (Rhow * Rv * T) / (Dv * 1.0d-4 * es * 1.0d2) ![s/m^2]

do j = 1, 9
    S = S_list(j)
            !########## Set initial condition ########## 
    r = 0.01d-6 ! micro meter
            !########## Check the value ##########
    print *, "------------------------------------------------"
    print*,"dt = ",dt, "tmax = ", tmax, " nt = ", nt
    print*,"S = ", S
    print*,"a= ", a, " b= ", b
    print*,"Fk = ", Fk, "[s/m^2]"
    print*,"Fd = ", Fd, "[s/m^2]"
    print*,"m = ", Rhow * 4.0d0/3.0d0 * pi * r**3 * 1.0d3, "[g]" 
    print *, "------------------------------------------------"
            !########## Preparing file writing #########
    write(filename, '("dg_S_", F5.3, "_Tc_", F5.2, ".dat")') S, Tc
    open(unit = 10, file = trim(adjustl(filename)), status = "replace", action = "readwrite")
    print*, "Opening file : ", trim(adjustl(filename))
            !########## Start couting cputime ##########
    call cpu_time(start_time)
            !########## scheme and writing file ########
    write(10,'(F12.5,1X,F12.8)') 0.0d0, r * 1.0d6
    do i = 1, nt
        if ( r <= 0.0d0 ) then
            stop
        else if ( r < 1.0d-9 ) then
            stop
        end if
        Kohler = 1.0d0 + a / r - b/r**3
        r_new = r + (S - Kohler)/(Fk + Fd) * (dt / r) 

        if (r_new >= 1.0d-6) then
            print *, "************************************************"
            print *, "Time to reach 1um: ", i * dt
            print *, "************************************************"
            exit
        end if

            !########## Writing file ###########
        !if(mod(i,100) == 0) then
            write(10,'(F12.5,1X,F12.8)')i * dt, r_new * 1.0d6
        !end if
                !########## Copying array ##########
        r = r_new
    end do
            !########## Finish writing file ##########
    close(10)
    print*,"Data has been written."
            !########## finish couting cputime #########
    call cpu_time(finish_time)
            !########## output the execution time. #####
    print*,"Fortran execution time (seconds): ",finish_time - start_time
end do
end program diffusion_growth