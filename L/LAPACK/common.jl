using BinaryBuilder, Pkg

# LAPACK mirrors the OpenBLAS build, whereas LAPACK32 mirrors the OpenBLAS32 build.

version = v"3.12.0"

# Collection of sources required to build lapack
sources = [
    GitSource("https://github.com/Reference-LAPACK/lapack",
              "04b044e020a3560ccfa9988c8a80a1fb7083fc2e"),
    DirectorySource("../bundled"),
]

# Bash recipe for building across all platforms

function lapack_script(;lapack32::Bool=false)
    script = """
    LAPACK32=$(lapack32)
    """

    script *= raw"""
    cd $WORKSPACE/srcdir/lapack*

    atomic_patch -p1 $WORKSPACE/srcdir/patches/cmake.patch

    if [[ "${target}" == *-mingw* ]]; then
        BLAS="blastrampoline-5"
    else
        BLAS="blastrampoline"
    fi

    FFLAGS=-ffixed-line-length-none
    if [[ ${nbits} == 64 ]] && [[ "${LAPACK32}" != "true" ]]; then
      FFLAGS="${FFLAGS} -cpp -DUSE_ISNAN -fdefault-integer-8"

      syms=(
        CAXPBY CAXPY CBBCSD CBDSQR CCOPY CDOTC CDOTU CGBBRD CGBCON CGBEQU
        CGBEQUB CGBMV CGBRFS CGBSV CGBSVX CGBTF2 CGBTRF CGBTRS CGEADD CGEBAK
        CGEBAL CGEBD2 CGEBRD CGECON CGEDMD CGEDMDQ CGEEQU CGEEQUB CGEES CGEESX
        CGEEV CGEEVX CGEHD2 CGEHRD CGEJSV CGELQ CGELQ2 CGELQF CGELQT CGELQT3
        CGELS CGELSD CGELSS CGELST CGELSY CGEMLQ CGEMLQT CGEMM CGEMM3M CGEMQR
        CGEMQRT CGEMV CGEQL2 CGEQLF CGEQP3 CGEQP3RK CGEQR CGEQR2 CGEQR2P
        CGEQRF CGEQRFP CGEQRT CGEQRT2 CGEQRT3 CGERC CGERFS CGERQ2 CGERQF CGERU
        CGESC2 CGESDD CGESV CGESVD CGESVDQ CGESVDX CGESVJ CGESVX CGETC2 CGETF2
        CGETRF CGETRF2 CGETRI CGETRS CGETSLS CGETSQRHRT CGGBAK CGGBAL CGGES
        CGGES3 CGGESX CGGEV CGGEV3 CGGEVX CGGGLM CGGHD3 CGGHRD CGGLSE CGGQRF
        CGGRQF CGGSVD3 CGGSVP3 CGSVJ0 CGSVJ1 CGTCON CGTRFS CGTSV CGTSVX CGTTRF
        CGTTRS CGTTS2 CHB2STKERNELS CHB2STKERNELS CHBEV CHBEV2STAGE
        CHBEV2STAGE CHBEVD CHBEVD2STAGE CHBEVD2STAGE CHBEVX CHBEVX2STAGE
        CHBEVX2STAGE CHBGST CHBGV CHBGVD CHBGVX CHBMV CHBTRD CHECON CHECON3
        CHECON3 CHECONROOK CHECONROOK CHEEQUB CHEEV CHEEV2STAGE CHEEV2STAGE
        CHEEVD CHEEVD2STAGE CHEEVD2STAGE CHEEVR CHEEVR2STAGE CHEEVR2STAGE
        CHEEVX CHEEVX2STAGE CHEEVX2STAGE CHEGS2 CHEGST CHEGV CHEGV2STAGE
        CHEGV2STAGE CHEGVD CHEGVX CHEMM CHEMV CHER CHER2 CHER2K CHERFS CHERK
        CHESV CHESVAA CHESVAA CHESVAA2STAGE CHESVAA2STAGE CHESVRK CHESVRK
        CHESVROOK CHESVROOK CHESVX CHESWAPR CHETD2 CHETF2 CHETF2RK CHETF2RK
        CHETF2ROOK CHETF2ROOK CHETRD CHETRD2STAGE CHETRD2STAGE CHETRDHB2ST
        CHETRDHB2ST CHETRDHE2HB CHETRDHE2HB CHETRF CHETRFAA CHETRFAA
        CHETRFAA2STAGE CHETRFAA2STAGE CHETRFRK CHETRFRK CHETRFROOK CHETRFROOK
        CHETRI CHETRI2 CHETRI2X CHETRI3 CHETRI3 CHETRI3X CHETRI3X CHETRIROOK
        CHETRIROOK CHETRS CHETRS2 CHETRS3 CHETRS3 CHETRSAA CHETRSAA
        CHETRSAA2STAGE CHETRSAA2STAGE CHETRSROOK CHETRSROOK CHFRK CHGEQZ
        CHLATRANSTYPE CHLATRANSTYPE CHPCON CHPEV CHPEVD CHPEVX CHPGST CHPGV
        CHPGVD CHPGVX CHPMV CHPR CHPR2 CHPRFS CHPSV CHPSVX CHPTRD CHPTRF
        CHPTRI CHPTRS CHSEIN CHSEQR CIMATCOPY CLABRD CLACGV CLACN2 CLACON
        CLACP2 CLACPY CLACRM CLACRT CLADIV CLAED0 CLAED7 CLAED8 CLAEIN CLAESY
        CLAEV2 CLAG2Z CLAGGE CLAGHE CLAGS2 CLAGSY CLAGTM CLAHEF CLAHEFAA
        CLAHEFAA CLAHEFRK CLAHEFRK CLAHEFROOK CLAHEFROOK CLAHILB CLAHQR CLAHR2
        CLAIC1 CLAKF2 CLALS0 CLALSA CLALSD CLAMSWLQ CLAMTSQR CLANGB CLANGE
        CLANGT CLANHB CLANHE CLANHF CLANHP CLANHS CLANHT CLANSB CLANSP CLANSY
        CLANTB CLANTP CLANTR CLAPLL CLAPMR CLAPMT CLAQGB CLAQGE CLAQHB CLAQHE
        CLAQHP CLAQP2 CLAQP2RK CLAQP3RK CLAQPS CLAQR0 CLAQR1 CLAQR2 CLAQR3
        CLAQR4 CLAQR5 CLAQSB CLAQSP CLAQSY CLAQZ0 CLAQZ1 CLAQZ2 CLAQZ3 CLAR1V
        CLAR2V CLARCM CLARF CLARFB CLARFBGETT CLARFG CLARFGP CLARFT CLARFX
        CLARFY CLARGE CLARGV CLARND CLARNV CLAROR CLAROT CLARRV CLARTG CLARTV
        CLARZ CLARZB CLARZT CLASCL CLASET CLASR CLASSQ CLASWLQ CLASWP CLASYF
        CLASYFAA CLASYFAA CLASYFRK CLASYFRK CLASYFROOK CLASYFROOK CLATBS
        CLATDF CLATM1 CLATM2 CLATM3 CLATM5 CLATM6 CLATME CLATMR CLATMS CLATMT
        CLATPS CLATRD CLATRS CLATRS3 CLATRZ CLATSQR CLAUNHRCOLGETRFNP
        CLAUNHRCOLGETRFNP CLAUNHRCOLGETRFNP2 CLAUNHRCOLGETRFNP2 CLAUU2 CLAUUM
        COMATCOPY CPBCON CPBEQU CPBRFS CPBSTF CPBSV CPBSVX CPBTF2 CPBTRF
        CPBTRS CPFTRF CPFTRI CPFTRS CPOCON CPOEQU CPOEQUB CPORFS CPOSV CPOSVX
        CPOTF2 CPOTRF CPOTRF2 CPOTRI CPOTRS CPPCON CPPEQU CPPRFS CPPSV CPPSVX
        CPPTRF CPPTRI CPPTRS CPSTF2 CPSTRF CPTCON CPTEQR CPTRFS CPTSV CPTSVX
        CPTTRF CPTTRS CPTTS2 CROT CROTG CRSCL CSBMV CSCAL CSPCON CSPMV CSPR
        CSPR2 CSPRFS CSPSV CSPSVX CSPTRF CSPTRI CSPTRS CSROT CSRSCL CSSCAL
        CSTEDC CSTEGR CSTEIN CSTEMR CSTEQR CSWAP CSYCON CSYCON3 CSYCON3
        CSYCONROOK CSYCONROOK CSYCONV CSYCONVF CSYCONVFROOK CSYCONVFROOK
        CSYEQUB CSYMM CSYMV CSYR CSYR2 CSYR2K CSYRFS CSYRK CSYSV CSYSVAA
        CSYSVAA CSYSVAA2STAGE CSYSVAA2STAGE CSYSVRK CSYSVRK CSYSVROOK
        CSYSVROOK CSYSVX CSYSWAPR CSYTF2 CSYTF2RK CSYTF2RK CSYTF2ROOK
        CSYTF2ROOK CSYTRF CSYTRFAA CSYTRFAA CSYTRFAA2STAGE CSYTRFAA2STAGE
        CSYTRFRK CSYTRFRK CSYTRFROOK CSYTRFROOK CSYTRI CSYTRI2 CSYTRI2X
        CSYTRI3 CSYTRI3 CSYTRI3X CSYTRI3X CSYTRIROOK CSYTRIROOK CSYTRS CSYTRS2
        CSYTRS3 CSYTRS3 CSYTRSAA CSYTRSAA CSYTRSAA2STAGE CSYTRSAA2STAGE
        CSYTRSROOK CSYTRSROOK CTBCON CTBMV CTBRFS CTBSV CTBTRS CTFSM CTFTRI
        CTFTTP CTFTTR CTGEVC CTGEX2 CTGEXC CTGSEN CTGSJA CTGSNA CTGSY2 CTGSYL
        CTPCON CTPLQT CTPLQT2 CTPMLQT CTPMQRT CTPMV CTPQRT CTPQRT2 CTPRFB
        CTPRFS CTPSV CTPTRI CTPTRS CTPTTF CTPTTR CTRCON CTREVC CTREVC3 CTREXC
        CTRMM CTRMV CTRRFS CTRSEN CTRSM CTRSNA CTRSV CTRSYL CTRSYL3 CTRTI2
        CTRTRI CTRTRS CTRTTF CTRTTP CTZRZF CUNBDB CUNBDB1 CUNBDB2 CUNBDB3
        CUNBDB4 CUNBDB5 CUNBDB6 CUNCSD CUNCSD2BY1 CUNG2L CUNG2R CUNGBR CUNGHR
        CUNGL2 CUNGLQ CUNGQL CUNGQR CUNGR2 CUNGRQ CUNGTR CUNGTSQR CUNGTSQRROW
        CUNHRCOL CUNHRCOL CUNM22 CUNM2L CUNM2R CUNMBR CUNMHR CUNML2 CUNMLQ
        CUNMQL CUNMQR CUNMR2 CUNMR3 CUNMRQ CUNMRZ CUNMTR CUPGTR CUPMTR DAMAX
        DAMIN DASUM DAXPBY DAXPY DBBCSD DBDSDC DBDSQR DBDSVDX DCABS1 DCOMBSSQ
        DCOPY DDISNA DDOT DGBBRD DGBCON DGBEQU DGBEQUB DGBMV DGBRFS DGBSV
        DGBSVX DGBTF2 DGBTRF DGBTRS DGEADD DGEBAK DGEBAL DGEBD2 DGEBRD DGECON
        DGEDMD DGEDMDQ DGEEQU DGEEQUB DGEES DGEESX DGEEV DGEEVX DGEHD2 DGEHRD
        DGEJSV DGELQ DGELQ2 DGELQF DGELQT DGELQT3 DGELS DGELSD DGELSS DGELST
        DGELSY DGEMLQ DGEMLQT DGEMM DGEMQR DGEMQRT DGEMV DGEQL2 DGEQLF DGEQP3
        DGEQP3RK DGEQR DGEQR2 DGEQR2P DGEQRF DGEQRFP DGEQRT DGEQRT2 DGEQRT3
        DGER DGERFS DGERQ2 DGERQF DGESC2 DGESDD DGESV DGESVD DGESVDQ DGESVDX
        DGESVJ DGESVX DGETC2 DGETF2 DGETRF DGETRF2 DGETRI DGETRS DGETSLS
        DGETSQRHRT DGGBAK DGGBAL DGGES DGGES3 DGGESX DGGEV DGGEV3 DGGEVX
        DGGGLM DGGHD3 DGGHRD DGGLSE DGGQRF DGGRQF DGGSVD3 DGGSVP3 DGSVJ0
        DGSVJ1 DGTCON DGTRFS DGTSV DGTSVX DGTTRF DGTTRS DGTTS2 DHGEQZ DHSEIN
        DHSEQR DIMATCOPY DISNAN DLABAD DLABRD DLACN2 DLACON DLACPY DLADIV
        DLADIV1 DLADIV2 DLAE2 DLAEBZ DLAED0 DLAED1 DLAED2 DLAED3 DLAED4 DLAED5
        DLAED6 DLAED7 DLAED8 DLAED9 DLAEDA DLAEIN DLAEV2 DLAEXC DLAG2 DLAG2S
        DLAGGE DLAGS2 DLAGSY DLAGTF DLAGTM DLAGTS DLAGV2 DLAHILB DLAHQR DLAHR2
        DLAIC1 DLAISNAN DLAKF2 DLALN2 DLALS0 DLALSA DLALSD DLAMC3 DLAMCH
        DLAMRG DLAMSWLQ DLAMTSQR DLANEG DLANGB DLANGE DLANGT DLANHS DLANSB
        DLANSF DLANSP DLANST DLANSY DLANTB DLANTP DLANTR DLANV2
        DLAORHRCOLGETRFNP DLAORHRCOLGETRFNP DLAORHRCOLGETRFNP2
        DLAORHRCOLGETRFNP2 DLAPLL DLAPMR DLAPMT DLAPY2 DLAPY3 DLAQGB DLAQGE
        DLAQP2 DLAQP2RK DLAQP3RK DLAQPS DLAQR0 DLAQR1 DLAQR2 DLAQR3 DLAQR4
        DLAQR5 DLAQSB DLAQSP DLAQSY DLAQTR DLAQZ0 DLAQZ1 DLAQZ2 DLAQZ3 DLAQZ4
        DLAR1V DLAR2V DLARAN DLARF DLARFB DLARFBGETT DLARFG DLARFGP DLARFT
        DLARFX DLARFY DLARGE DLARGV DLARMM DLARND DLARNV DLAROR DLAROT DLARRA
        DLARRB DLARRC DLARRD DLARRE DLARRF DLARRJ DLARRK DLARRR DLARRV DLARTG
        DLARTGP DLARTGS DLARTV DLARUV DLARZ DLARZB DLARZT DLAS2 DLASCL DLASD0
        DLASD1 DLASD2 DLASD3 DLASD4 DLASD5 DLASD6 DLASD7 DLASD8 DLASDA DLASDQ
        DLASDT DLASET DLASQ1 DLASQ2 DLASQ3 DLASQ4 DLASQ5 DLASQ6 DLASR DLASRT
        DLASSQ DLASV2 DLASWLQ DLASWP DLASY2 DLASYF DLASYFAA DLASYFAA DLASYFRK
        DLASYFRK DLASYFROOK DLASYFROOK DLAT2S DLATBS DLATDF DLATM1 DLATM2
        DLATM3 DLATM5 DLATM6 DLATM7 DLATME DLATMR DLATMS DLATMT DLATPS DLATRD
        DLATRS DLATRS3 DLATRZ DLATSQR DLAUU2 DLAUUM DMAX DMIN DNRM2 DOMATCOPY
        DOPGTR DOPMTR DORBDB DORBDB1 DORBDB2 DORBDB3 DORBDB4 DORBDB5 DORBDB6
        DORCSD DORCSD2BY1 DORG2L DORG2R DORGBR DORGHR DORGL2 DORGLQ DORGQL
        DORGQR DORGR2 DORGRQ DORGTR DORGTSQR DORGTSQRROW DORHRCOL DORHRCOL
        DORM22 DORM2L DORM2R DORMBR DORMHR DORML2 DORMLQ DORMQL DORMQR DORMR2
        DORMR3 DORMRQ DORMRZ DORMTR DPBCON DPBEQU DPBRFS DPBSTF DPBSV DPBSVX
        DPBTF2 DPBTRF DPBTRS DPFTRF DPFTRI DPFTRS DPOCON DPOEQU DPOEQUB DPORFS
        DPOSV DPOSVX DPOTF2 DPOTRF DPOTRF2 DPOTRI DPOTRS DPPCON DPPEQU DPPRFS
        DPPSV DPPSVX DPPTRF DPPTRI DPPTRS DPSTF2 DPSTRF DPTCON DPTEQR DPTRFS
        DPTSV DPTSVX DPTTRF DPTTRS DPTTS2 DROT DROTG DROTM DROTMG
        DROUNDUPLWORK DRSCL DSB2STKERNELS DSB2STKERNELS DSBEV DSBEV2STAGE
        DSBEV2STAGE DSBEVD DSBEVD2STAGE DSBEVD2STAGE DSBEVX DSBEVX2STAGE
        DSBEVX2STAGE DSBGST DSBGV DSBGVD DSBGVX DSBMV DSBTRD DSCAL DSDOT
        DSECND DSFRK DSGESV DSPCON DSPEV DSPEVD DSPEVX DSPGST DSPGV DSPGVD
        DSPGVX DSPMV DSPOSV DSPR DSPR2 DSPRFS DSPSV DSPSVX DSPTRD DSPTRF
        DSPTRI DSPTRS DSTEBZ DSTEDC DSTEGR DSTEIN DSTEMR DSTEQR DSTERF DSTEV
        DSTEVD DSTEVR DSTEVX DSUM DSWAP DSYCON DSYCON3 DSYCON3 DSYCONROOK
        DSYCONROOK DSYCONV DSYCONVF DSYCONVFROOK DSYCONVFROOK DSYEQUB DSYEV
        DSYEV2STAGE DSYEV2STAGE DSYEVD DSYEVD2STAGE DSYEVD2STAGE DSYEVR
        DSYEVR2STAGE DSYEVR2STAGE DSYEVX DSYEVX2STAGE DSYEVX2STAGE DSYGS2
        DSYGST DSYGV DSYGV2STAGE DSYGV2STAGE DSYGVD DSYGVX DSYMM DSYMV DSYR
        DSYR2 DSYR2K DSYRFS DSYRK DSYSV DSYSVAA DSYSVAA DSYSVAA2STAGE
        DSYSVAA2STAGE DSYSVRK DSYSVRK DSYSVROOK DSYSVROOK DSYSVX DSYSWAPR
        DSYTD2 DSYTF2 DSYTF2RK DSYTF2RK DSYTF2ROOK DSYTF2ROOK DSYTRD
        DSYTRD2STAGE DSYTRD2STAGE DSYTRDSB2ST DSYTRDSB2ST DSYTRDSY2SB
        DSYTRDSY2SB DSYTRF DSYTRFAA DSYTRFAA DSYTRFAA2STAGE DSYTRFAA2STAGE
        DSYTRFRK DSYTRFRK DSYTRFROOK DSYTRFROOK DSYTRI DSYTRI2 DSYTRI2X
        DSYTRI3 DSYTRI3 DSYTRI3X DSYTRI3X DSYTRIROOK DSYTRIROOK DSYTRS DSYTRS2
        DSYTRS3 DSYTRS3 DSYTRSAA DSYTRSAA DSYTRSAA2STAGE DSYTRSAA2STAGE
        DSYTRSROOK DSYTRSROOK DTBCON DTBMV DTBRFS DTBSV DTBTRS DTFSM DTFTRI
        DTFTTP DTFTTR DTGEVC DTGEX2 DTGEXC DTGSEN DTGSJA DTGSNA DTGSY2 DTGSYL
        DTPCON DTPLQT DTPLQT2 DTPMLQT DTPMQRT DTPMV DTPQRT DTPQRT2 DTPRFB
        DTPRFS DTPSV DTPTRI DTPTRS DTPTTF DTPTTR DTRCON DTREVC DTREVC3 DTREXC
        DTRMM DTRMV DTRRFS DTRSEN DTRSM DTRSNA DTRSV DTRSYL DTRSYL3 DTRTI2
        DTRTRI DTRTRS DTRTTF DTRTTP DTZRZF DZAMAX DZAMIN DZASUM DZNRM2 DZSUM
        DZSUM1 FINI GOTOSETNUMTHREADS ICAMAX ICAMIN ICMAX1 IDAMAX IDAMIN IDMAX
        IDMIN IEEECK ILACLC ILACLR ILADIAG ILADLC ILADLR ILAENV ILAENV2STAGE
        ILAPREC ILASLC ILASLR ILATRANS ILAUPLO ILAVER ILAZLC ILAZLR INIT
        IPARAM2STAGE IPARMQ ISAMAX ISAMIN ISMAX ISMIN IZAMAX IZAMIN IZMAX1
        LSAME LSAMEN SAMAX SAMIN SASUM SAXPBY SAXPY SBBCSD SBDSDC SBDSQR
        SBDSVDX SCABS1 SCAMAX SCAMIN SCASUM SCNRM2 SCOMBSSQ SCOPY SCSUM SCSUM1
        SDISNA SDOT SDSDOT SECOND SGBBRD SGBCON SGBEQU SGBEQUB SGBMV SGBRFS
        SGBSV SGBSVX SGBTF2 SGBTRF SGBTRS SGEADD SGEBAK SGEBAL SGEBD2 SGEBRD
        SGECON SGEDMD SGEDMDQ SGEEQU SGEEQUB SGEES SGEESX SGEEV SGEEVX SGEHD2
        SGEHRD SGEJSV SGELQ SGELQ2 SGELQF SGELQT SGELQT3 SGELS SGELSD SGELSS
        SGELST SGELSY SGEMLQ SGEMLQT SGEMM SGEMQR SGEMQRT SGEMV SGEQL2 SGEQLF
        SGEQP3 SGEQP3RK SGEQR SGEQR2 SGEQR2P SGEQRF SGEQRFP SGEQRT SGEQRT2
        SGEQRT3 SGER SGERFS SGERQ2 SGERQF SGESC2 SGESDD SGESV SGESVD SGESVDQ
        SGESVDX SGESVJ SGESVX SGETC2 SGETF2 SGETRF SGETRF2 SGETRI SGETRS
        SGETSLS SGETSQRHRT SGGBAK SGGBAL SGGES SGGES3 SGGESX SGGEV SGGEV3
        SGGEVX SGGGLM SGGHD3 SGGHRD SGGLSE SGGQRF SGGRQF SGGSVD3 SGGSVP3
        SGSVJ0 SGSVJ1 SGTCON SGTRFS SGTSV SGTSVX SGTTRF SGTTRS SGTTS2 SHGEQZ
        SHSEIN SHSEQR SIMATCOPY SISNAN SLABAD SLABRD SLACN2 SLACON SLACPY
        SLADIV SLADIV1 SLADIV2 SLAE2 SLAEBZ SLAED0 SLAED1 SLAED2 SLAED3 SLAED4
        SLAED5 SLAED6 SLAED7 SLAED8 SLAED9 SLAEDA SLAEIN SLAEV2 SLAEXC SLAG2
        SLAG2D SLAGGE SLAGS2 SLAGSY SLAGTF SLAGTM SLAGTS SLAGV2 SLAHILB SLAHQR
        SLAHR2 SLAIC1 SLAISNAN SLAKF2 SLALN2 SLALS0 SLALSA SLALSD SLAMC3
        SLAMCH SLAMRG SLAMSWLQ SLAMTSQR SLANEG SLANGB SLANGE SLANGT SLANHS
        SLANSB SLANSF SLANSP SLANST SLANSY SLANTB SLANTP SLANTR SLANV2
        SLAORHRCOLGETRFNP SLAORHRCOLGETRFNP SLAORHRCOLGETRFNP2
        SLAORHRCOLGETRFNP2 SLAPLL SLAPMR SLAPMT SLAPY2 SLAPY3 SLAQGB SLAQGE
        SLAQP2 SLAQP2RK SLAQP3RK SLAQPS SLAQR0 SLAQR1 SLAQR2 SLAQR3 SLAQR4
        SLAQR5 SLAQSB SLAQSP SLAQSY SLAQTR SLAQZ0 SLAQZ1 SLAQZ2 SLAQZ3 SLAQZ4
        SLAR1V SLAR2V SLARAN SLARF SLARFB SLARFBGETT SLARFG SLARFGP SLARFT
        SLARFX SLARFY SLARGE SLARGV SLARMM SLARND SLARNV SLAROR SLAROT SLARRA
        SLARRB SLARRC SLARRD SLARRE SLARRF SLARRJ SLARRK SLARRR SLARRV SLARTG
        SLARTGP SLARTGS SLARTV SLARUV SLARZ SLARZB SLARZT SLAS2 SLASCL SLASD0
        SLASD1 SLASD2 SLASD3 SLASD4 SLASD5 SLASD6 SLASD7 SLASD8 SLASDA SLASDQ
        SLASDT SLASET SLASQ1 SLASQ2 SLASQ3 SLASQ4 SLASQ5 SLASQ6 SLASR SLASRT
        SLASSQ SLASV2 SLASWLQ SLASWP SLASY2 SLASYF SLASYFAA SLASYFAA SLASYFRK
        SLASYFRK SLASYFROOK SLASYFROOK SLATBS SLATDF SLATM1 SLATM2 SLATM3
        SLATM5 SLATM6 SLATM7 SLATME SLATMR SLATMS SLATMT SLATPS SLATRD SLATRS
        SLATRS3 SLATRZ SLATSQR SLAUU2 SLAUUM SMAX SMIN SNRM2 SOMATCOPY SOPGTR
        SOPMTR SORBDB SORBDB1 SORBDB2 SORBDB3 SORBDB4 SORBDB5 SORBDB6 SORCSD
        SORCSD2BY1 SORG2L SORG2R SORGBR SORGHR SORGL2 SORGLQ SORGQL SORGQR
        SORGR2 SORGRQ SORGTR SORGTSQR SORGTSQRROW SORHRCOL SORHRCOL SORM22
        SORM2L SORM2R SORMBR SORMHR SORML2 SORMLQ SORMQL SORMQR SORMR2 SORMR3
        SORMRQ SORMRZ SORMTR SPBCON SPBEQU SPBRFS SPBSTF SPBSV SPBSVX SPBTF2
        SPBTRF SPBTRS SPFTRF SPFTRI SPFTRS SPOCON SPOEQU SPOEQUB SPORFS SPOSV
        SPOSVX SPOTF2 SPOTRF SPOTRF2 SPOTRI SPOTRS SPPCON SPPEQU SPPRFS SPPSV
        SPPSVX SPPTRF SPPTRI SPPTRS SPSTF2 SPSTRF SPTCON SPTEQR SPTRFS SPTSV
        SPTSVX SPTTRF SPTTRS SPTTS2 SROT SROTG SROTM SROTMG SROUNDUPLWORK
        SRSCL SSB2STKERNELS SSB2STKERNELS SSBEV SSBEV2STAGE SSBEV2STAGE SSBEVD
        SSBEVD2STAGE SSBEVD2STAGE SSBEVX SSBEVX2STAGE SSBEVX2STAGE SSBGST
        SSBGV SSBGVD SSBGVX SSBMV SSBTRD SSCAL SSFRK SSPCON SSPEV SSPEVD
        SSPEVX SSPGST SSPGV SSPGVD SSPGVX SSPMV SSPR SSPR2 SSPRFS SSPSV SSPSVX
        SSPTRD SSPTRF SSPTRI SSPTRS SSTEBZ SSTEDC SSTEGR SSTEIN SSTEMR SSTEQR
        SSTERF SSTEV SSTEVD SSTEVR SSTEVX SSUM SSWAP SSYCON SSYCON3 SSYCON3
        SSYCONROOK SSYCONROOK SSYCONV SSYCONVF SSYCONVFROOK SSYCONVFROOK
        SSYEQUB SSYEV SSYEV2STAGE SSYEV2STAGE SSYEVD SSYEVD2STAGE SSYEVD2STAGE
        SSYEVR SSYEVR2STAGE SSYEVR2STAGE SSYEVX SSYEVX2STAGE SSYEVX2STAGE
        SSYGS2 SSYGST SSYGV SSYGV2STAGE SSYGV2STAGE SSYGVD SSYGVX SSYMM SSYMV
        SSYR SSYR2 SSYR2K SSYRFS SSYRK SSYSV SSYSVAA SSYSVAA SSYSVAA2STAGE
        SSYSVAA2STAGE SSYSVRK SSYSVRK SSYSVROOK SSYSVROOK SSYSVX SSYSWAPR
        SSYTD2 SSYTF2 SSYTF2RK SSYTF2RK SSYTF2ROOK SSYTF2ROOK SSYTRD
        SSYTRD2STAGE SSYTRD2STAGE SSYTRDSB2ST SSYTRDSB2ST SSYTRDSY2SB
        SSYTRDSY2SB SSYTRF SSYTRFAA SSYTRFAA SSYTRFAA2STAGE SSYTRFAA2STAGE
        SSYTRFRK SSYTRFRK SSYTRFROOK SSYTRFROOK SSYTRI SSYTRI2 SSYTRI2X
        SSYTRI3 SSYTRI3 SSYTRI3X SSYTRI3X SSYTRIROOK SSYTRIROOK SSYTRS SSYTRS2
        SSYTRS3 SSYTRS3 SSYTRSAA SSYTRSAA SSYTRSAA2STAGE SSYTRSAA2STAGE
        SSYTRSROOK SSYTRSROOK STBCON STBMV STBRFS STBSV STBTRS STFSM STFTRI
        STFTTP STFTTR STGEVC STGEX2 STGEXC STGSEN STGSJA STGSNA STGSY2 STGSYL
        STPCON STPLQT STPLQT2 STPMLQT STPMQRT STPMV STPQRT STPQRT2 STPRFB
        STPRFS STPSV STPTRI STPTRS STPTTF STPTTR STRCON STREVC STREVC3 STREXC
        STRMM STRMV STRRFS STRSEN STRSM STRSNA STRSV STRSYL STRSYL3 STRTI2
        STRTRI STRTRS STRTTF STRTTP STZRZF XERBLA XERBLAARRAY XERBLAARRAY
        ZAXPBY ZAXPY ZBBCSD ZBDSQR ZCGESV ZCOPY ZCPOSV ZDOTC ZDOTU ZDROT
        ZDRSCL ZDSCAL ZGBBRD ZGBCON ZGBEQU ZGBEQUB ZGBMV ZGBRFS ZGBSV ZGBSVX
        ZGBTF2 ZGBTRF ZGBTRS ZGEADD ZGEBAK ZGEBAL ZGEBD2 ZGEBRD ZGECON ZGEDMD
        ZGEDMDQ ZGEEQU ZGEEQUB ZGEES ZGEESX ZGEEV ZGEEVX ZGEHD2 ZGEHRD ZGEJSV
        ZGELQ ZGELQ2 ZGELQF ZGELQT ZGELQT3 ZGELS ZGELSD ZGELSS ZGELST ZGELSY
        ZGEMLQ ZGEMLQT ZGEMM ZGEMM3M ZGEMQR ZGEMQRT ZGEMV ZGEQL2 ZGEQLF ZGEQP3
        ZGEQP3RK ZGEQR ZGEQR2 ZGEQR2P ZGEQRF ZGEQRFP ZGEQRT ZGEQRT2 ZGEQRT3
        ZGERC ZGERFS ZGERQ2 ZGERQF ZGERU ZGESC2 ZGESDD ZGESV ZGESVD ZGESVDQ
        ZGESVDX ZGESVJ ZGESVX ZGETC2 ZGETF2 ZGETRF ZGETRF2 ZGETRI ZGETRS
        ZGETSLS ZGETSQRHRT ZGGBAK ZGGBAL ZGGES ZGGES3 ZGGESX ZGGEV ZGGEV3
        ZGGEVX ZGGGLM ZGGHD3 ZGGHRD ZGGLSE ZGGQRF ZGGRQF ZGGSVD3 ZGGSVP3
        ZGSVJ0 ZGSVJ1 ZGTCON ZGTRFS ZGTSV ZGTSVX ZGTTRF ZGTTRS ZGTTS2
        ZHB2STKERNELS ZHB2STKERNELS ZHBEV ZHBEV2STAGE ZHBEV2STAGE ZHBEVD
        ZHBEVD2STAGE ZHBEVD2STAGE ZHBEVX ZHBEVX2STAGE ZHBEVX2STAGE ZHBGST
        ZHBGV ZHBGVD ZHBGVX ZHBMV ZHBTRD ZHECON ZHECON3 ZHECON3 ZHECONROOK
        ZHECONROOK ZHEEQUB ZHEEV ZHEEV2STAGE ZHEEV2STAGE ZHEEVD ZHEEVD2STAGE
        ZHEEVD2STAGE ZHEEVR ZHEEVR2STAGE ZHEEVR2STAGE ZHEEVX ZHEEVX2STAGE
        ZHEEVX2STAGE ZHEGS2 ZHEGST ZHEGV ZHEGV2STAGE ZHEGV2STAGE ZHEGVD ZHEGVX
        ZHEMM ZHEMV ZHER ZHER2 ZHER2K ZHERFS ZHERK ZHESV ZHESVAA ZHESVAA
        ZHESVAA2STAGE ZHESVAA2STAGE ZHESVRK ZHESVRK ZHESVROOK ZHESVROOK ZHESVX
        ZHESWAPR ZHETD2 ZHETF2 ZHETF2RK ZHETF2RK ZHETF2ROOK ZHETF2ROOK ZHETRD
        ZHETRD2STAGE ZHETRD2STAGE ZHETRDHB2ST ZHETRDHB2ST ZHETRDHE2HB
        ZHETRDHE2HB ZHETRF ZHETRFAA ZHETRFAA ZHETRFAA2STAGE ZHETRFAA2STAGE
        ZHETRFRK ZHETRFRK ZHETRFROOK ZHETRFROOK ZHETRI ZHETRI2 ZHETRI2X
        ZHETRI3 ZHETRI3 ZHETRI3X ZHETRI3X ZHETRIROOK ZHETRIROOK ZHETRS ZHETRS2
        ZHETRS3 ZHETRS3 ZHETRSAA ZHETRSAA ZHETRSAA2STAGE ZHETRSAA2STAGE
        ZHETRSROOK ZHETRSROOK ZHFRK ZHGEQZ ZHPCON ZHPEV ZHPEVD ZHPEVX ZHPGST
        ZHPGV ZHPGVD ZHPGVX ZHPMV ZHPR ZHPR2 ZHPRFS ZHPSV ZHPSVX ZHPTRD ZHPTRF
        ZHPTRI ZHPTRS ZHSEIN ZHSEQR ZIMATCOPY ZLABRD ZLACGV ZLACN2 ZLACON
        ZLACP2 ZLACPY ZLACRM ZLACRT ZLADIV ZLAED0 ZLAED7 ZLAED8 ZLAEIN ZLAESY
        ZLAEV2 ZLAG2C ZLAGGE ZLAGHE ZLAGS2 ZLAGSY ZLAGTM ZLAHEF ZLAHEFAA
        ZLAHEFAA ZLAHEFRK ZLAHEFRK ZLAHEFROOK ZLAHEFROOK ZLAHILB ZLAHQR ZLAHR2
        ZLAIC1 ZLAKF2 ZLALS0 ZLALSA ZLALSD ZLAMSWLQ ZLAMTSQR ZLANGB ZLANGE
        ZLANGT ZLANHB ZLANHE ZLANHF ZLANHP ZLANHS ZLANHT ZLANSB ZLANSP ZLANSY
        ZLANTB ZLANTP ZLANTR ZLAPLL ZLAPMR ZLAPMT ZLAQGB ZLAQGE ZLAQHB ZLAQHE
        ZLAQHP ZLAQP2 ZLAQP2RK ZLAQP3RK ZLAQPS ZLAQR0 ZLAQR1 ZLAQR2 ZLAQR3
        ZLAQR4 ZLAQR5 ZLAQSB ZLAQSP ZLAQSY ZLAQZ0 ZLAQZ1 ZLAQZ2 ZLAQZ3 ZLAR1V
        ZLAR2V ZLARCM ZLARF ZLARFB ZLARFBGETT ZLARFG ZLARFGP ZLARFT ZLARFX
        ZLARFY ZLARGE ZLARGV ZLARND ZLARNV ZLAROR ZLAROT ZLARRV ZLARTG ZLARTV
        ZLARZ ZLARZB ZLARZT ZLASCL ZLASET ZLASR ZLASSQ ZLASWLQ ZLASWP ZLASYF
        ZLASYFAA ZLASYFAA ZLASYFRK ZLASYFRK ZLASYFROOK ZLASYFROOK ZLAT2C
        ZLATBS ZLATDF ZLATM1 ZLATM2 ZLATM3 ZLATM5 ZLATM6 ZLATME ZLATMR ZLATMS
        ZLATMT ZLATPS ZLATRD ZLATRS ZLATRS3 ZLATRZ ZLATSQR ZLAUNHRCOLGETRFNP
        ZLAUNHRCOLGETRFNP ZLAUNHRCOLGETRFNP2 ZLAUNHRCOLGETRFNP2 ZLAUU2 ZLAUUM
        ZOMATCOPY ZPBCON ZPBEQU ZPBRFS ZPBSTF ZPBSV ZPBSVX ZPBTF2 ZPBTRF
        ZPBTRS ZPFTRF ZPFTRI ZPFTRS ZPOCON ZPOEQU ZPOEQUB ZPORFS ZPOSV ZPOSVX
        ZPOTF2 ZPOTRF ZPOTRF2 ZPOTRI ZPOTRS ZPPCON ZPPEQU ZPPRFS ZPPSV ZPPSVX
        ZPPTRF ZPPTRI ZPPTRS ZPSTF2 ZPSTRF ZPTCON ZPTEQR ZPTRFS ZPTSV ZPTSVX
        ZPTTRF ZPTTRS ZPTTS2 ZROT ZROTG ZRSCL ZSBMV ZSCAL ZSPCON ZSPMV ZSPR
        ZSPR2 ZSPRFS ZSPSV ZSPSVX ZSPTRF ZSPTRI ZSPTRS ZSTEDC ZSTEGR ZSTEIN
        ZSTEMR ZSTEQR ZSWAP ZSYCON ZSYCON3 ZSYCON3 ZSYCONROOK ZSYCONROOK
        ZSYCONV ZSYCONVF ZSYCONVFROOK ZSYCONVFROOK ZSYEQUB ZSYMM ZSYMV ZSYR
        ZSYR2 ZSYR2K ZSYRFS ZSYRK ZSYSV ZSYSVAA ZSYSVAA ZSYSVAA2STAGE
        ZSYSVAA2STAGE ZSYSVRK ZSYSVRK ZSYSVROOK ZSYSVROOK ZSYSVX ZSYSWAPR
        ZSYTF2 ZSYTF2RK ZSYTF2RK ZSYTF2ROOK ZSYTF2ROOK ZSYTRF ZSYTRFAA
        ZSYTRFAA ZSYTRFAA2STAGE ZSYTRFAA2STAGE ZSYTRFRK ZSYTRFRK ZSYTRFROOK
        ZSYTRFROOK ZSYTRI ZSYTRI2 ZSYTRI2X ZSYTRI3 ZSYTRI3 ZSYTRI3X ZSYTRI3X
        ZSYTRIROOK ZSYTRIROOK ZSYTRS ZSYTRS2 ZSYTRS3 ZSYTRS3 ZSYTRSAA ZSYTRSAA
        ZSYTRSAA2STAGE ZSYTRSAA2STAGE ZSYTRSROOK ZSYTRSROOK ZTBCON ZTBMV
        ZTBRFS ZTBSV ZTBTRS ZTFSM ZTFTRI ZTFTTP ZTFTTR ZTGEVC ZTGEX2 ZTGEXC
        ZTGSEN ZTGSJA ZTGSNA ZTGSY2 ZTGSYL ZTPCON ZTPLQT ZTPLQT2 ZTPMLQT
        ZTPMQRT ZTPMV ZTPQRT ZTPQRT2 ZTPRFB ZTPRFS ZTPSV ZTPTRI ZTPTRS ZTPTTF
        ZTPTTR ZTRCON ZTREVC ZTREVC3 ZTREXC ZTRMM ZTRMV ZTRRFS ZTRSEN ZTRSM
        ZTRSNA ZTRSV ZTRSYL ZTRSYL3 ZTRTI2 ZTRTRI ZTRTRS ZTRTTF ZTRTTP ZTZRZF
        ZUNBDB ZUNBDB1 ZUNBDB2 ZUNBDB3 ZUNBDB4 ZUNBDB5 ZUNBDB6 ZUNCSD
        ZUNCSD2BY1 ZUNG2L ZUNG2R ZUNGBR ZUNGHR ZUNGL2 ZUNGLQ ZUNGQL ZUNGQR
        ZUNGR2 ZUNGRQ ZUNGTR ZUNGTSQR ZUNGTSQRROW ZUNHRCOL ZUNHRCOL ZUNM22
        ZUNM2L ZUNM2R ZUNMBR ZUNMHR ZUNML2 ZUNMLQ ZUNMQL ZUNMQR ZUNMR2 ZUNMR3
        ZUNMRQ ZUNMRZ ZUNMTR ZUPGTR ZUPMTR disnan sisnan
      )

      for sym in ${syms[@]}; do
         FFLAGS+=("-D${sym}=${sym}_64")
      done

      CMAKE_FLAGS+=(-DCMAKE_Fortran_FLAGS=\"${FFLAGS[*]}\")
    fi

    mkdir build && cd build
    cmake .. "${CMAKE_FLAGS[@]}" \
       -DCMAKE_INSTALL_PREFIX="$prefix" \
       -DCMAKE_FIND_ROOT_PATH="$prefix" \
       -DCMAKE_TOOLCHAIN_FILE="${CMAKE_TARGET_TOOLCHAIN}" \
       -DCMAKE_BUILD_TYPE=Release \
       -DBUILD_SHARED_LIBS=ON \
       -DTEST_FORTRAN_COMPILER=OFF \
       -DBLAS_LIBRARIES="-L${libdir} -l${BLAS}"

    make -j${nproc}
    make install

    if [[ -f "${libdir}/libblas.${dlext}" ]]; then
        echo "Error: libblas.${dlext} has been built, linking to libblastrampoline did not work"
        exit 1
    fi

    # Rename liblapack.${dlext} into liblapack32.${dlext}
    if [[ "${LAPACK32}" == "true" ]]; then
        mv -v ${libdir}/liblapack.${dlext} ${libdir}/liblapack32.${dlext}
        # If there were links that are now broken, fix 'em up
        for l in $(find ${prefix}/lib -xtype l); do
          if [[ $(basename $(readlink ${l})) == liblapack ]]; then
            ln -vsf liblapack32.${dlext} ${l}
          fi
        done
        PATCHELF_FLAGS=()
        # ppc64le and aarch64 have 64 kB page sizes, don't muck up the ELF section load alignment
        if [[ ${target} == aarch64-* || ${target} == powerpc64le-* ]]; then
          PATCHELF_FLAGS+=(--page-size 65536)
        fi
        if [[ ${target} == *linux* ]] || [[ ${target} == *freebsd* ]]; then
          patchelf ${PATCHELF_FLAGS[@]} --set-soname liblapack32.${dlext} ${libdir}/liblapack32.${dlext}
        elif [[ ${target} == *apple* ]]; then
          install_name_tool -id liblapack32.${dlext} ${libdir}/liblapack32.${dlext}
        fi
    fi
    """
end

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = expand_gfortran_versions(supported_platforms())

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("CompilerSupportLibraries_jll"),
    Dependency("libblastrampoline_jll"; compat="5.4.0"),
]
