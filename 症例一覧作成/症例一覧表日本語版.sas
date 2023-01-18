/***************************************************
 * SDTM�f�[�^����Ǘ�ꗗ�\(���{���)���쐬����    *
 * �A���A�O���Ö�̓��{�ꉻ�͂��Ă��Ȃ�            *
 * ������                                          *
 * �E�팱��ID/AGE SEX/ACTARM                       *
 * �EMH�i�����ǁA�������j                          *
 * �E�O���Ái��܁j                                *
 * �E���^�J�n��/���^�I����/���~�����/���~���R     *
 * �E�����܂��͎��S��/���S���R                     *
 * 		   S.Takahara Kanazawa University Hospital *
 ***************************************************/

%let	study	=	�e�X�g���� (TEST study) ;
%let	sdtm	=	R:\02.General\61.SAS���ʃ��W���[��\CDISC�ėpSAS�v���O����\�e�X�g�f�[�^2\ ;
%let	MedDRAf	=	R:\02.General\51.�V�X�e���֘A\21.����\MedDRA 22.0\ASCII\MDRA_J220 ;
%let	outf	=	\\DM-SERVER2\FRedirect$\takahara\Desktop\�Ǘ�ꗗ�\_j.xlsx ;
%let	mhongo	=	ONGOING ;			* MH�Ōp�����i�������ǁj�̏ꍇ��MHENRF ;
%let	mhpre	=	OTHER ;				* MH�ō����ǁE�������̏ꍇ��MHCAT ;
%let	cmpre	=	PRIOR ;				* CM�őO���Â̏ꍇ��CMCAT ;

/*
 * �}�N��
 */
%macro	readds	( domain , select ) ;
	PROC IMPORT OUT	= &domain 
		DATAFILE	= "&sdtm\&domain..csv" 
		DBMS		= CSV	REPLACE ;
		GETNAMES	=  YES ;
		DATAROW		= 2 ;
		GUESSINGROWS= 10000 ; 
	RUN;
	data	&domain ;
		set		&domain ;
			where	&select ;
	run ;
%mend ;
/*
 * DM
 */
%readds		( dm , usubjid ne '' ) ;
/*
 * MH�i�������A�����ǁj
 */
%readds		( mh , mhcat eq "&MHPRE" ) ;
/*
 * MedDRA-J��LLT��ǂݍ��݁E�E�E�p��łȂ�s�v ;
 */
PROC IMPORT OUT= WORK.LLT_J 
            DATAFILE= "&MedDRAf\llt_j.asc" 
            DBMS=DLM REPLACE;
     DELIMITER='24'x; 
     GETNAMES=NO;
     DATAROW=1; 
     GUESSINGROWS=max; 
RUN;
/*
 * MedDRA-J�ƃ}�[�W
 */		
proc sort	data	=	mh ;
	by	mhlltcd ;
run ;

data	mh1 ;
	merge	mh(in=a)
			llt_j(rename=(var1=mhlltcd)) ;
		by	mhlltcd ;
	if	a ;
	length	mhlltx	$ 200
			mhstdtt	mhendtt	$ 4 ;											* �N�̂ݎ擾�̏ꍇ�B�f�[�^�ɉ����ďC�� ;
	if	mhstdtc eq .	then	mhstdtt	=	'UNK' ;							* �f�[�^���e�L�X�g�ɂȂ��Ă���ꍇ�͓K�X�C�� ;
	else						mhstdtt	=	put ( mhstdtc , best4. ) ;		* �N�����Ŏ擾���Ă���ꍇ�͕K�v�ɉ����ăt�H�[�}�b�g���C�� ;
	if	mhendtc eq .	then	mhendtt	=	'UNK' ;
	else						mhendtt	=	put ( mhendtc , best4. ) ;		* �N�����Ŏ擾���Ă���ꍇ�͕K�v�ɉ����ăt�H�[�}�b�g���C�� ;
	if	mhenrf eq "&MHONGO"	then
		mhlltx	=	trim ( var2 ) || ' ' || trim ( left ( mhstdtt ) ) || ' - *' ;
	else
		mhlltx	=	trim ( var2 ) || ' ' || trim ( left ( mhstdtt ) ) || ' -' || trim ( left ( mhendtt ) ) ;
	keep	usubjid mhlltx ;
run ;
proc sort	data	=	mh1 ;
	by	usubjid ;
run ;

/*
 * CM�i�O���Áj
 */
%readds		( cm , cmcat eq "&CMPRE" ) ;
proc sort	data	=	cm ;
	by	usubjid	cmrefid ;
run ;
data	cm ;
	set		cm ;
	length	cmtrtx	$ 200
			cmstdtt	cmendtt	$ 10 ;											* �f�[�^�ɉ����ďC�� ;
	if	cmstdtc eq .	then	cmstdtt	=	'UNK' ;							* �f�[�^���e�L�X�g�ɂȂ��Ă���ꍇ�͓K�X�C�� ;
	else						cmstdtt	=	put ( cmstdtc , yymmdd10. ) ;
	if	cmendtc eq .	then	cmendtt	=	'UNK' ;
	else						cmendtt	=	put ( cmendtc , yymmdd10. ) ;
	cmtrtx	=	trim ( cmtrt ) || ' (' || trim ( cmstdtt ) || '-' || trim ( cmendtt ) || ')' ;
	keep	usubjid	cmtrtx ;
run ;
/*
 * ���~�E�E��
 */
%readds		( ds , dsterm ne 'COMPLETED' ) ;
/*
 * ���S
 */
%readds		( dd , ddorres ne '' ) ;
/*
 * �f�[�^����
 */
data	background ;
	merge	dm
			mh1
			cm
			ds(keep=usubjid dsterm)
			dd(keep=usubjid ddorres) ;
		by	usubjid ;
	retain	l ;
	if	first.usubjid	then	l	=	1 ;
	else						l	=	l + 1 ;
	output ;
	if	last.usubjid	then	do ;
		do ix	=	l+1 to 4 ;
			output ;
		end ;
	end ;
	drop	l	ix ;
run ;
data	background2 ;
	length	c1		$ 20
			mhlltx	cmtrtx	mht	cmt	dos	$ 200
			dth		$ 20 ;
	set		background ;
		by	usubjid ;
	retain	l	mht	cmt ;
	if	first.usubjid	then	do ;
		l	=	1 ;
		c1	=	usubjid ;
		dos	=	put ( rfxstdtc , yymmdd10. ) ;
		mht	=	mhlltx ;
		cmt	=	cmtrtx ;
		if	dthfl eq 'Y'	then	dth	=	'���S ' || put	( dthdtc , yymmdd10. ) ;
		else						dth	=	'����' ;
	end ;
	else do ;
		if	mhlltx eq mht	then	mhlltx	=	' ' ;
		else						mht	=	mhlltx ;
		if	cmtrtx eq cmt	then	cmtrtx	=	' ' ;
		else						cmt	=	cmtrtx ;
		l	=	l + 1 ;
		select	( l ) ;
			when	( 2 )	do ;
				c1	=	put ( age , 2. ) || ' / ' || sex ;
				dos	=	put ( rfxendtc , yymmdd10. ) ;
				dth	=	ddorres ;
				end ;
			when	( 3 )	do ;
				c1	=	actarm ;
				dos	=	put ( rfendtc , yymmdd10. ) ;
				end ;
			when	( 4 )	do ;
				dos	=	dsterm ;
				end ;
			otherwise		c1	=	' ' ;
		end ;
	end ;
	if	last.usubjid	then	l	=	99 ;
	keep	usubjid	c1	mhlltx	cmtrtx	dos	dth	l ddorres ;
	label	c1		=	'�Ǘ�ԍ�#�N�� ����#���^�Q'
			mhlltx	=	'�����ǁE������##*�F����'
			cmtrtx	=	'�O���Ö�'
			dos		=	'���^�J�n��#���^�I����#���~�����#���~���R'
			dth		=	'�����܂��͎��S��#���S���R'
			;
run ;
proc sort	data	=	background2 ;
	by	usubjid	l ;
run ;
/*
 * Excel�o��
 */
title		"&study �Ǘ�ꗗ�\" ;
footnote	'&P/&N' ;
ods	excel	file	=	"&outf"
			options ( 
				sheet_name	= '�Ǘ�ꗗ�\���{���'
				orientation	= 'landscape'
				pages_fitwidth	=	'1'	
				pages_fitheight	=	'999'
				row_repeat		=	'1'
			) ;
proc report	data	=	background2
				split='#'
				style(report)	=	[borderwidth=1.5 bordercolor=black]
				style(header)	=	[just=c borderbottomstyle=double borderbottomcolor=black]
				;

	columns	L c1	mhlltx	cmtrtx	dos	dth	;

	define	c1		/ style	=	[width=60pt just=c] ;
	define	mhlltx	/ style	=	[width=200pt] ;
	define	cmtrtx	/ style	=	[width=300pt] ;
	define	dos		/ style	=	[width=150pt] ;
	define	dth		/ style	=	[width=100pt] ;
	define	l		/ display	noprint ;

	compute	c1 ;
		if	l eq 99	then
			call	define	( _row_ ,	"style/merge" ,	"style=[borderbottomcolor=black borderbottomstyle=double bordertopcolor=white bordertopwidth=5]" ) ;
		else
			call	define	( _row_ ,	"style/merge" ,	"style=[borderbottomcolor=white borderbottomwidth=5 bordertopcolor=white bordertopwidth=5]" ) ;
	endcomp ;
run ;
ods	excel	close ;
