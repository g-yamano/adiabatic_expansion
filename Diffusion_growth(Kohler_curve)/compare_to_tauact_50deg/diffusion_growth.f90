program diffusion_growth
implicit none
            !########## Set value ##########
integer(8) ::                  i
real ::                        start_time, finish_time ! for counting Cpu_time.
double precision, parameter :: dt   = 1.0d-7, &
                               tmax = 3.0d0
integer(8), parameter       :: nt   = nint(tmax / dt, 8)
            !########## Parameter ##########
double precision, parameter :: pi   = 3.14159265d0
double precision, parameter :: T    = 323.15d0  ! [K]　周囲温度
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
double precision            :: S, r_crit, s_crit
logical                     :: reached_rcrit
double precision, dimension(6) :: S_list = (/ 1.01d0, 1.011d0, 1.0101d0, 1.01001d0, 1.010001d0, 1.0100001d0 /)
integer                     :: j
character(len=50)           :: filename
double precision            :: tau_act

            !########## Calculation ########## 

a  = (2 * sigma * 1.0d-3) / (Rv * Rhow * T)
!b  = (3 * vhf * mv * M * 1.0d-3) / (4 * pi * Rhow * ms)
b  = 9.8075380110759942d-25
Fk = (Le / ( Rv * T ) - 1.0e0) * ( Le * Rhow ) / (Ka * T) ![s/m^2]
Fd = (Rhow * Rv * T) / (Dv * 1.0d-4 * es * 1.0d2) ![s/m^2]

do j = 1, 6
    S = S_list(j)
            !########## Set initial condition ########## 
    r = 0.01d-6 ! micro meter
    reached_rcrit = .false.

    r_crit = (3.0d0 * b / a)**(0.5d0)
    s_crit = (4.0d0 * a**3 / (27.0d0 * b))**(0.5d0)

    print *, "------------------------------------------------"
    if (S > (1.0d0 + s_crit)) then
        ! Eq. 8 in Arabas and Shima (2017)
        ! term1: r_c^(5/2) / sqrt(A)
        ! term2: (rho_w / rho_vs) / D_eff  ==> (Fk + Fd)
        ! term3: pi / sqrt(RH - RH_c)      ==> pi / sqrt(S - (1.0 + s_crit))
        
        tau_act = (r_crit**2.5d0 / sqrt(a)) * (Fk + Fd) * (pi / sqrt(S - (1.0d0 + s_crit)))
        
        print *, "analitycal tau_act (s): ", tau_act
    else
        print *, "Calculated tau_act (s): Inf (S <= Scrit)"
    end if
            !########## Check the value ##########
    print*,"dt = ",dt, "tmax = ", tmax, " nt = ", nt
    print*,"S = ", S
    print*,"a= ", a, " b= ", b
    print*,"r_crit (um) = ", r_crit * 1.0d6
    print*,"s_crit (%)  = ", s_crit * 100.0d0
    print*,"Fk = ", Fk, "[s/m^2]"
    print*,"Fd = ", Fd, "[s/m^2]"
    print*,"m = ", Rhow * 4.0d0/3.0d0 * pi * r**3 * 1.0d3, "[g]" 
    print *, "------------------------------------------------"
            !########## Preparing file writing #########
    write(filename, '("dg_S_", F10.8, "_Tc_", F5.2, ".dat")') S, Tc
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

        if (.not. reached_rcrit .and. r_new >= r_crit) then
            print *, "************************************************"
            print *, "Time to reach r_crit: ", i * dt
            reached_rcrit = .true.
        end if

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