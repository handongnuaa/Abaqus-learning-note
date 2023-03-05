      SUBROUTINE UMAT(STRESS,STATEV,DDSDDE,SSE,SPD,SCD,
     1     RPL,DDSDDT,DRPLDE,DRPLDT,
     2     STRAN,DSTRAN,TIME,DTIME,TEMP,DTEMP,PREDEF,DPRED,CMNAME,
     3     NDI,NSHR,NTENS,NSTATV,PROPS,NPROPS,COORDS,DROT,PNEWDT,
     4     CELENT,DFGRD0,DFGRD1,NOEL,NPT,LAYER,KSPT,KSTEP,KINC)
C     
      INCLUDE 'ABA_PARAM.INC'
C     
      CHARACTER*80 CMNAME
      DIMENSION STRESS(NTENS),STATEV(NSTATV),
     1     DDSDDE(NTENS,NTENS),
     2     DDSDDT(NTENS),DRPLDE(NTENS),
     3     STRAN(NTENS),DSTRAN(NTENS),TIME(2),PREDEF(1),DPRED(1),
     4     PROPS(NPROPS),COORDS(3),DROT(3,3),DFGRD0(3,3),DFGRD1(3,3)
C      
      DIMENSION STRANT(6)
      DIMENSION C(6,6), CD(6,6)
      DIMENSION DDFDE(6), DDMDE(6), DDDDE(6), DCDDF(6,6), DCDDM(6,6),
     1           DCDDD(6,6)
      DIMENSION ATEMP1(6), ATEMP2(6), ATEMP3(6)
      DIMENSION OLD_STRESS(6)
      DIMENSION DOLD_STRESS(6),D_STRESS(6)
      PARAMETER (ZERO = 0.D0,ONE = 1.D0,TWO = 2.D0,HALF = 0.5D0)
      PARAMETER (DVMAX = 0.99D0,DVMIN = 0.D0)
C****************************
C
C     GET THE MATERIAL PROPERTIES---ENGINEERING CONSTANTS
C
      E1  = PROPS(1)          !YOUNG'S MODULUS IN DIRECTION 1
      E2  = PROPS(2)          !YOUNG'S MODULUS IN DIRECTION 2 OR DIRECTION 3
      U12 = PROPS(3)          !POISON'S RATIO POI_12 OR POI_13
      U23 = PROPS(4)          !POISON'S RATIO POI_23
      G12 = PROPS(5)          !SHEAR MODULUS IN 12 PLANE OR 13 PLANE
      G23 = PROPS(6)          !SHEAR MODULUS IN 23 PLANE
      U21 = U12 / E1 * E2    !POI_21
C     
C     GET THE FAILURE PROPERTIES
C
      XTE  = PROPS(7)          !TENSION FAILURE STRAIN IN 1 DIRECTION
      XC  = PROPS(8)          !COMPRESSION FAILURE STRESS IN 1 DIRECTION
      YT  = PROPS(9)          !TENSION FAILURE STRESS IN 2 DIRECTION                               ! OR 3 DIRECTION
      YC  = PROPS(10)         !COMPRESSION FAILURE STRESS IN 2 DIRECTION                              ! OR 3 DIRECTION
      SL  = PROPS(11)         !SHEAR FAILURE STRESS IN 1-2 PLANE
      ST  = PROPS(12)         !SHEAR FAILURE STRESS IN 2-3 PLANE


      GFT = PROPS(13)         !FRACTURE ENERGY IN FIBER IN TENSION
      GFC = PROPS(14)         !FRACTURE ENERGY IN FIBER IN COMPRESSION
      GMT = PROPS(15)         !FRACTURE ENERGY IN MATRIX IN TENSION
      GMC = PROPS(16)         !FRACTURE ENERGY IN MATRIX IN COMPRESSION
      GD  = PROPS(17)         !FRACTURE ENERGY IN DELAMINATION

      ETA = PROPS(18)         !VISCOSITY FOR REGULARIZATION

c      PARA1 = PROPS(19)
      PARA2 = PROPS(19)
      PARA3 = PROPS(20)
      PARA4 = PROPS(21)

      PARA1 = E1
C     
C     CALCULATE THE STRAIN AT THE END OF THE INCREMENT
C     
      DO I = 1, NTENS
         STRANT(I) = STRAN(I) + DSTRAN(I)
      END DO
C     
C     FILL THE 6X6 FULL STIFFNESS MATRIX
C
      DO I = 1, 6
         DO J = 1, 6
            C(I,J)=ZERO
         END DO
      END DO
      TEMP = ONE - TWO * U12 * U21 - U23 ** TWO
     1      - TWO * U12 * U21 * U23
      C(1,1) = E1 * (ONE - U23 ** TWO) / TEMP
      C(2,2) = E2 * (ONE - U12 * U21) / TEMP
      C(3,3) = C(2,2)
      C(1,2) = E2 * (U12 + U12 * U23) / TEMP
      C(2,1) = C(1,2)
      C(1,3) = C(1,2)
      C(3,1) = C(1,3)
      C(2,3) = E2 * (U23 + U12 * U21) / TEMP
      C(3,2) = C(2,3)
      C(4,4) = G12
      C(5,5) = G12
      C(6,6) = G23

      DFOLD  = STATEV(1)
      DMOLD  = STATEV(2)
      DDOLD  = STATEV(3)
      DFVOLD = STATEV(4)
      DMVOLD = STATEV(5)
      DDVOLD = STATEV(6)

      E11Max = STATEV(13)
      E11Failure = STATEV(14)

      E11 = STRANT(1)

      FLAG_LOAD=-1.0*ONE
      FLAG_FAILURE=-1.0*ONE

      IF (E11 .GT. E11Max) THEN
         E11Max = E11
         STATEV(13) = E11
         FLAG_LOAD=ONE
      END IF
      d_dm=ZERO
      CALL NonlinearBehavior(E11Max,C,d_dm,E11Failure,
     1   PARA1,PARA2,PARA3,PARA4)
c      IF (E11Failure .GT. ZERO) THEN
c         IF (E11Failure .GT. Emc1 .AND. E11Failure .LT. Emc2) THEN
c            Amc = 238.1353
c            Bmc = 39.7638
c            Cmc = 0.03151
c            E11mc=(Amc+Bmc*LOG(100.0*E11Failure-Cmc))/E11Failure
c            C(1,1) = E11mc * (ONE - U23 ** TWO) / TEMP
c         ELSE IF (E11Failure .GE. Emc2) THEN
c            Amc = 163.6132
c            Bmc = 227.78175
c            Cmc = 0.185
c            E11mc = (Amc + Bmc*(100.0*E11Failure-Cmc))/E11Failure         
c            C(1,1) = E11mc * (ONE - U23 ** TWO) / TEMP
c         END IF
c      END IF

     

C
C     CALCULATE THE FAILURE STRAIN BY FAILURE STRESS
C
      EXT = XTE !XT / C(1,1) !FAILURE STRAIN 1 DIRECTION IN TENSION
      EXC = XC / C(1,1) !FAILURE STRAIN 1 DIRECTION IN COMPRESSION
      EYT = YT / C(2,2) !FAILURE STRAIN 2 DIRECTION IN TENSILE
      EYC = YC / C(2,2) !FAILURE STRAIN 2 DIRECTION IN COMPRESSIVE
      ESL = SL / C(4,4) !FAILURE SHEAR STRAIN IN 12 PLANE
                        ! OR 13 PLANE...ENGINEERING STRAIN
      EST = ST / C(6,6) !FAILURE SHEAR STRAIN IN 23 PLANE
                        ! ...ENGINEERING STRAIN
C     
C     CHECK THE FAILURE INITIATION CONDITION
C     



      

      CALL CheckFailureIni(EXT, EXC, EYT, EYC, ESL, EST, STRANT,
     1                     GFT, GFC, GMT, GMC, GD, CELENT, C, DF, DM,
     2                     DD, DDFDE, DDMDE, DDDDE, NTENS, DFOLD,
     3                     DMOLD, DDOLD, E11Failure, FLAG_FAILURE)
C     
C     ! USE VISCOUS REGULARIZATION
C     
      DFV = ETA / (ETA + DTIME) * DFVOLD + DTIME / (ETA + DTIME) * DF
      DMV = ETA / (ETA + DTIME) * DMVOLD + DTIME / (ETA + DTIME) * DM
      DDV = ETA / (ETA + DTIME) * DDVOLD + DTIME / (ETA + DTIME) * DD
      DFV = MIN(DFV, DVMAX)
      DFV = MAX(DFV, DVMIN)
      DMV = MIN(DMV, DVMAX)
      DMV = MAX(DMV, DVMIN)
      DDV = MIN(DDV, DVMAX)
      DDV = MAX(DDV, DVMIN)
   
C     SAVE THE OLD STRESS TO OLD_STRESS
C
      DO I = 1, NTENS
         OLD_STRESS(I) = STRESS(I)
      END DO
C
C     CALL ROUTINE TO CALCULATE THE STRESS
C     CALCULATE THE STRESS IF THERE'S NO VISCOUS REGULARIZATION
      CALL GetStress(C,CD,DF,DM,DD,D_STRESS,STRANT,NTENS)
C     CALCULATE THE STRESS IF THERE'S VISCOUS REGULARIZATION
      CALL GetStress(C,CD,DFV,DMV,DDV,STRESS,STRANT,NTENS)      
C     GET THE OLD STRESS IF THERE'S NO VISCOUS REGULARIZATION
      DO I=1,NTENS
         DOLD_STRESS(I) = STATEV(I+6)
      END DO
C     SAVE THE CURRENT STRESS IF THERE'S NO VISCOUS REGULARIZATION
      DO I=1,NTENS
         STATEV(I+6) = D_STRESS(I)
      END DO           
C     
C     CALCULATE THE DERIVATIVE MATRIX DC/DDF, DC/DDM, DC/DDD OF THE DAMAGED MATRIX
C     
      CALL ElasticDerivative(C,DFV,DMV,DDV,DCDDF,DCDDM,DCDDD)
C     
C     UPDATE THE JACOBIAN MATRIX
C
      DO I = 1, NTENS
         ATEMP1(I) = ZERO
         DO J = 1, NTENS
            ATEMP1(I) = ATEMP1(I) + DCDDF(I,J) * STRANT(J)
         END DO
      END DO
           
      DO I = 1, NTENS
         ATEMP2(I) = ZERO
         DO J = 1, NTENS
            ATEMP2(I) = ATEMP2(I) + DCDDM(I,J) * STRANT(J)
         END DO
      END DO
C
      DO I = 1, NTENS
         ATEMP3(I) = ZERO
         DO J = 1, NTENS
            ATEMP3(I) = ATEMP3(I) + DCDDD(I,J) * STRANT(J)
         END DO
      END DO      
C
      DO I = 1, NTENS
         DO J = 1, NTENS
            DDSDDE(I,J) = CD(I,J) + (ATEMP3(I) * DDDDE(J) + ATEMP2(I)
     1                   * DDMDE(J) + ATEMP1(I) * DDFDE(J)) * DTIME
     2                   / (DTIME + ETA)
         END DO
      END DO
      
      IF (FLAG_FAILURE .LT. ZERO .AND. FLAG_LOAD .GT. ZERO) THEN 
         A_TEMP=(ONE - U23 ** TWO) / TEMP
         B_TEMP=PARA1+2.0*PARA2*E11
     1      +3.0*PARA3*E11*E11
     2      +4.0*PARA4*E11*E11*E11
         DDSDDE(1,1) = A_TEMP*B_TEMP
      END IF
C     
C     TO UPDATE THE STATE VARIABLE
C     
      STATEV(1) = DF
      STATEV(2) = DM
      STATEV(3) = DD
      STATEV(4) = DFV
      STATEV(5) = DMV
      STATEV(6) = DDV

      STATEV(14) = E11Failure
      
      STATEV(15) = (ONE - DFV) * C(1,1)
      STATEV(16) = (ONE - DFV)
      STATEV(17) = E11Max
      STATEV(18) = C(1,1)
      STATEV(19) = CD(1,1)

      STATEV(20) = d_dm
 
C    
C     TO COMPUTE THE ENERGY
C     
      DO I = 1, NDI
         SSE = SSE + HALF * (STRESS(I) + OLD_STRESS(I)) * DSTRAN(I)
      END DO
      DO I = NDI+1, NTENS
         SSE = SSE + (STRESS(I) + OLD_STRESS(I)) * DSTRAN(I)
      END DO
C     TO COMPUTE THE INTERNAL ENERGY WITHOUT VISCOUS REGULARIZATION
      DO I = 1, NDI
         SCD = SCD + HALF * (STRESS(I) + OLD_STRESS(I)
     1        -D_STRESS(I)-DOLD_STRESS(I)) * DSTRAN(I)
      END DO
      DO I = NDI+1, NTENS
         SCD = SCD + (STRESS(I) + OLD_STRESS(I)
     1        -D_STRESS(I)-DOLD_STRESS(I)) * DSTRAN(I)
      END DO
      RETURN
      END     
C******************************************************************************
C     TO CHECK THE FAILURE INITIATION AND THE CORRESPONDING DERIVATIVE*********
C******************************************************************************
      SUBROUTINE CheckFailureIni(EXT, EXC, EYT, EYC, ESL, EST, STRANT,
     1     GFT, GFC, GMT, GMC, GD, CELENT, C, DF, DM, DD, DDFDE, DDMDE,
     2     DDDDE, NTENS, DFOLD, DMOLD, DDOLD, E11Failure, FLAG_FAILURE)
      INCLUDE 'ABA_PARAM.INC'
      DIMENSION DDFDE(6), DDMDE(6), DDDDE(6), STRANT(6), C(6,6)
      DIMENSION DFFDE(6), DFMDE(6), DFDDE(6)
      PARAMETER (ZERO = 0.D0, ONE = 1.D0, TWO = 2.D0, HALF = 0.5D0)
C
      E11 = STRANT(1)
      E22 = STRANT(2)      
      E33 = STRANT(3)      
      E12 = STRANT(4)
      E13 = STRANT(5)
      E23 = STRANT(6)
C     
C     CHECK THE INITIATION CONDITION FOR MATRIX
C     FM > 1 THEN EVALUATE THE DAMAGE VARIABLE AND DERIVATIVE
C     
      TERM = (E12/ESL)**TWO + (E13/ESL)**TWO + (E23/EST)**TWO
     1       - E22*E33/EST**TWO
      IF ((E22 + E33) .GT. ZERO) THEN
      	 TERM = TERM + ((E22 + E33)/EYT)**TWO
      ELSE
      	 TERM = TERM + ((EYC/EST/TWO)**TWO - ONE)*(E22 + E33)/EYC
     1        + ((E22 + E33)/EST/TWO)**TWO
      END IF
      !IF (TERM .GT. ZERO) THEN
         FM = SQRT(TERM)
      !ELSE
      !   FM = ZERO
      !END IF
C
C     INITIALIZE THE ARRAY AND VARIABLE
C
      DM = ZERO
      DDMDFM = ZERO
      DO I = 1, 6
         DFMDE(I) = ZERO
         DDMDE(I) = ZERO
      END DO
      IF (FM .GT. ONE) THEN
C     CALCULATE DM, DDMDFM
         IF ((E22 + E33) .GT. ZERO) THEN   
            CALL DamageEvaluation(C(2,2), FM, GMT, CELENT, EYT, DM,
     1                            DDMDFM)
         ELSE
            CALL DamageEvaluation(C(2,2), FM, GMC, CELENT, EYC, DM,
     1                            DDMDFM)
         END IF
C     CALCULATE DFMDE, DDMDE
         IF (DM .GT. DMOLD) THEN
            IF ((E22 + E33) .GT. ZERO) THEN
               TERM1 = ONE/FM * (E22+E33)/EYT**TWO
               TERM2 = ONE/FM / EST**TWO/TWO
               DFMDE(2) = TERM1 - TERM2*E33
               DFMDE(3) = TERM1 - TERM2*E22
            ELSE
               TERM1 = ONE/FM/TWO * (((EYC/EST/TWO)**TWO - ONE) / EYC
     1                 + (E22+E33)/EST**TWO/TWO)
               TERM2 = ONE/FM/TWO / EST**TWO
               DFMDE(2) = TERM1 - TERM2*E33
               DFMDE(3) = TERM1 - TERM2*E22
            END IF
            DFMDE(4) = E12/FM/ESL**TWO
            DFMDE(5) = E13/FM/ESL**TWO
            DFMDE(6) = E23/FM/EST**TWO
            DO I = 1, 6
               DDMDE(I) = DFMDE(I) * DDMDFM
            END DO
         END IF
      END IF
      DM = MAX (DM, DMOLD)
C     
C     CHECK THE INITIATION CONDITION FOR FIBER
C     FF > 1 THEN CALCULATE THE DAMAGE VARIABLE AND DERIVATIVE
C     
	IF (E11 .GT. ZERO) THEN
	   FF = SQRT((E11/EXT)**TWO + (E12/ESL)**TWO + (E13/ESL)**TWO)
	ELSE
	   FF = ABS(E11/EXC)
	END IF
C
C     INITIALIZE THE ARRAY AND VARIABLE
C	
	DF = ZERO
	DDFDFF = ZERO
	DO I = 1, 6
         DFFDE(I) = ZERO
         DDFDE(I) = ZERO
	END DO
	IF (FF .GT. ONE) THEN
         FLAG_FAILURE = ONE

C     CALCULATE DF, DDFDFF
         IF (E11 .GT. ZERO) THEN
            CALL DamageEvaluation(C(1,1), FF, GFT, CELENT, EXT, DF,
     1                            DDFDFF)
            IF (E11Failure .EQ. ZERO) THEN
               E11Failure = E11
            ENDIF
         ELSE
            CALL DamageEvaluation(C(1,1), FF, GFC, CELENT, EXC, DF,
     1                            DDFDFF)
         END IF
C     CALCULATE DFFDE, DDFDE
         IF (DF .GT. DFOLD) THEN
            IF (E11 .GT. ZERO) THEN
               DFFDE(1) = ONE/FF * E11/EXT**TWO
               DFFDE(4) = ONE/FF * E12/ESL**TWO
               DFFDE(5) = ONE/FF * E13/ESL**TWO
            ELSE
               DFFDE(1) = ONE/FF * E11/EXC**TWO
            END IF
            DDFDE(1) = DFFDE(1) * DDFDFF
            DDFDE(4) = DFFDE(4) * DDFDFF
            DDFDE(5) = DFFDE(5) * DDFDFF
         END IF
	END IF
      DF = MAX (DF, DFOLD)

      IF (DF .GT. ZERO) THEN
        FLAG_FAILURE = ONE
      END IF
C     
C     CHECK THE INITIATION CONDITION FOR DELAMINATION
C     FD > 1 THEN CALCULATE THE DAMAGE VARIABLE AND DERIVATIVE
C       
      TERM = (E13/ESL)**TWO + (E23/EST)**TWO
      IF (E33 .GT. ZERO) THEN
         FD = SQRT(TERM + (E33/EYT)**TWO)
      ELSE
         FD = SQRT(TERM)
      END IF
C
C     INITIALIZE THE ARRAY AND VARIABLE
C	
	DD = ZERO
	DDDDFD = ZERO
	DO I = 1, 6
         DFDDE(I) = ZERO
         DDDDE(I) = ZERO
	END DO
	IF (FD .GT. ONE) THEN
C     CALCULATE DD, DDDDFD
         CALL DamageEvaluation(C(3,3), FD, GD, CELENT, EYT, DD, DDDDFD)
C     CALCULATE DFDDE, DDDDE
         IF (DD .GT. DDOLD) THEN
            IF (E33 .GT. ZERO) THEN
               DFDDE(3) = ONE/FD * E33/EYT**TWO
            END IF
            DFDDE(5) = ONE/FD * E13/ESL**TWO
            DFDDE(6) = ONE/FD * E23/EST**TWO
            DDDDE(3) = DFDDE(3) * DDDDFD
            DDDDE(5) = DFDDE(5) * DDDDFD
            DDDDE(6) = DFDDE(6) * DDDDFD
         END IF
	END IF
      DD = MAX (DD, DDOLD)
C
      RETURN
	END       
C******************************************************************************
C     SUBROUTINE TO EVALUATE THE DAMAGE AND THE
C     DERIVATIVE************************
C******************************************************************************
      SUBROUTINE DamageEvaluation(STIFF, F, GC, CELENT, EPIT, D, DDDF)
C     CALCULATE DAMAGE VARIABLE
      INCLUDE 'ABA_PARAM.INC'
      PARAMETER (DMAX = 0.99D0, DMIN = 0.D0, ONE = 1.D0, TWO= 2.D0)
      TERM1 = STIFF * EPIT**TWO * CELENT / GC
      TERM2 = (ONE - F) * TERM1
      D = ONE - EXP(TERM2) / F
      D = MIN (D, DMAX)
      D = MAX (D, DMIN)
C     CALCULATE THE DERIVATIVE OF DAMAGE VARIABLE WITH RESPECT TO FAILURE RITERION
      DDDF = (ONE / F + TERM1) * (ONE - D)
C
      RETURN
      END
C******************************************************************************
C CALCULATE THE STRESS BASED ON THE DAMAGE VARAIBLES***************************
C******************************************************************************
      SUBROUTINE GetStress(C,CD,DFV,DMV,DDV,STRESS,STRANT,NTENS)
      INCLUDE 'ABA_PARAM.INC'
      DIMENSION C(6,6),CD(6,6),STRESS(NTENS),STRANT(6)
      PARAMETER (ZERO=0.D0, ONE=1.D0)
      DO I = 1, 6
         DO J = 1, 6
            CD(I,J)=C(I,J)
         END DO
      END DO
C     CALCULATE CD
      IF((DFV .NE. ZERO) .OR. (DMV .NE. ZERO) .OR. (DDV .NE. ZERO))THEN
         CD(1,1) = (ONE - DFV) * C(1,1)
         CD(1,2) = (ONE - DFV) * (ONE - DMV) * C(1,2)
         CD(2,1) = CD(1,2)
         CD(1,3) = (ONE - DFV) * (ONE - DDV) * C(1,3)
         CD(3,1) = CD(1,3)
         CD(2,2) = (ONE - DMV) * C(2,2)
         CD(2,3) = (ONE - DMV) * (ONE - DDV) * C(2,3)
         CD(3,2) = CD(2,3)
         CD(3,3) = (ONE - DDV) * C(3,3)
         CD(4,4) = (ONE - DFV) * (ONE - DMV) * C(4,4)
         CD(5,5) = (ONE - DFV) * (ONE - DDV) * C(5,5)
         CD(6,6) = (ONE - DMV) * (ONE - DDV) * C(6,6)
      END IF
C     UPDATE THE STRESS STATE
      DO I = 1, NTENS
         STRESS(I)=ZERO
         DO J = 1, NTENS
            STRESS(I)=STRESS(I)+CD(I,J) * STRANT(J)
         END DO
      END DO
      RETURN
      END
C*******************************************************************************
C     SUBROUTINE TO GET THE DERIVATIVE MATRIX OF CONDENSE DAMAGED MATRIX OVER
C**** THE DAMAGE VARIABLE******************************************************
C*******************************************************************************
      SUBROUTINE ElasticDerivative(C,DFV,DMV,DDV,DCDDF,DCDDM,DCDDD)
      INCLUDE 'ABA_PARAM.INC'
      DIMENSION C(6,6), DCDDF(6,6), DCDDM(6,6), DCDDD(6,6)
      PARAMETER (ZERO = 0.D0, ONE = 1.D0, HALF = 0.5D0)
C     INITIALIZE THE DATA TO ZERO
      DO I = 1, 6
         DO J = 1, 6
            DCDDD(I,J) = ZERO
            DCDDM(I,J) = ZERO
            DCDDF(I,J) = ZERO
         END DO
      END DO
C     
C     CALCULATE DC/DDF
C     
      DCDDF(1,1) = - C(1,1)
      DCDDF(1,2) = - (ONE - DMV) * C(1,2)
      DCDDF(2,1) = DCDDF(1,2)
      DCDDF(1,3) = - (ONE - DDV) * C(1,3)
      DCDDF(3,1) = DCDDF(1,3)
      DCDDF(4,4) = - (ONE - DMV) * C(4,4)
      DCDDF(5,5) = - (ONE - DDV) * C(5,5)
C     
C     CALCULATE DC/DDM
C     
      DCDDM(1,2) = - (ONE - DFV) * C(1,2)
      DCDDM(2,1) = DCDDM(1,2)
      DCDDM(2,2) = -C(2,2)
      DCDDM(2,3) = - (ONE - DDV) * C(2,3)
      DCDDM(3,2) = DCDDM(2,3)
      DCDDM(4,4) = -(ONE - DFV) * C(4,4)
      DCDDM(6,6) = -(ONE - DDV) * C(6,6)
C     
C     CALCULATE DC/DDD
C     
      DCDDD(1,3) = - (ONE - DFV) * C(1,3)
      DCDDD(3,1) = DCDDD(1,3)
      DCDDD(2,3) = - (ONE - DMV) * C(2,3)
      DCDDD(3,2) = DCDDD(2,3)
      DCDDD(3,3) = - C(3,3)
      DCDDD(5,5) = -(ONE - DFV) * C(5,5)
      DCDDD(6,6) = -(ONE - DMV) * C(6,6)
      RETURN
      END

C*******************************************************************************
C     SUBROUTINE TO calculate nonlinear behavior
C*******************************************************************************
      SUBROUTINE NonlinearBehavior(E11max,C,d_dm,
     1   E11Failure,PARA1,PARA2,PARA3,PARA4)
      INCLUDE 'ABA_PARAM.INC'
      DIMENSION C(6,6), CD(6,6)
      PARAMETER (ZERO = 0.D0, ONE = 1.D0, HALF = 0.5D0)
      
      
      
      B_1=PARA1
      B_2=PARA2
      B_3=PARA3
      B_4=PARA4

      d_dm=ZERO
      
      d_dm=-B_2/B_1*E11max-B_3/B_1*E11max*E11max
     1 -B_4/B_1*E11max*E11max*E11max
      
      IF((E11Max .GT. E11Failure) .AND.
     1 (E11Failure .GT. ZERO))THEN
      d_dm=-B_2/B_1*E11Failure
     1 -B_3/B_1*E11Failure*E11Failure
     2 -B_4/B_1*E11Failure*E11Failure*E11Failure
      ENDIF


      C(1,1)=(ONE-d_dm)*C(1,1)
      C(1,2)=(ONE-d_dm)*C(1,2)
      C(2,1)=C(1,2)
      C(1,3)=(ONE-d_dm)*C(1,3)
      C(3,1)=C(1,3)
      C(4,4)=(ONE-d_dm)*C(4,4)
      C(5,5)=(ONE-d_dm)*C(5,5)


      RETURN
      END
C*******************************************************************************
C     SUBROUTINE TO calculate ddsdde(nonlinear)
C*******************************************************************************
      SUBROUTINE CalculateDDSDDE_nl(DDSDDE,C,d_dm,STRANT,DTIME,ETA,
     1   E11Failure,PARA1,PARA2,PARA3,PARA4)
      INCLUDE 'ABA_PARAM.INC'
      DIMENSION DDSDDE(6,6),DCDD_DM(6,6)
      DIMENSION ATEMP(6),DD_DMDE(6),STRANT(6)
      PARAMETER (ZERO = 0.D0, ONE = 1.D0, HALF = 0.5D0)
      
      E11 = STRANT(1)
      
      B_1=PARA1
      B_2=PARA2
      B_3=PARA3
      B_4=PARA4
      
      DO I = 1, 6
         DD_DMDE(I)=ZERO
         DO J = 1, 6
            DCDD_DM(I,J) = ZERO
         END DO
      END DO
      
      DCDD_DM(1,1)=-C(1,1)
      DCDD_DM(1,2)=-C(1,2)
      DCDD_DM(1,3)=-C(1,3)

      DCDD_DM(2,1)=-C(2,1)

      DCDD_DM(3,1)=-C(3,1)

      DCDD_DM(4,4)=-C(4,4)

      DCDD_DM(5,5)=-C(5,5)

      DO I = 1, 6
         ATEMP(I) = ZERO
         DO J = 1, 6
            ATEMP(I) = ATEMP(I) + DCDD_DM(I,J) * STRANT(J)
         END DO
      END DO

      
      DD_DMDE(1)=(-B_2*E11-B_3*E11*E11-B_4*E11*E11*E11)/B_1

      DO I = 1, 6
         DO J = 1, 6
            DDSDDE(I,J) = C(I,J) + (ATEMP(I) * DD_DMDE(J)) * DTIME
     2                   / (DTIME + ETA)
         END DO
      END DO

      RETURN
      END