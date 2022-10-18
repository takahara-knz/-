/***************************************************
 * SDTM�f�[�^����Ǘ�ꗗ�\���쐬����              *
 * ������                                          *
 * �E�팱��ID/AGE SEX/ACTARM                       *
 * �EMH�i�����ǁA�������j                          *
 * �E�O���Ái��܁j                                *
 * �E���^�J�n��/���^�I����/���~�����/���~���R     *
 * �E�����܂��͎��S��/���S���R                     *
 * 		   S.Takahara Kanazawa University Hospital *
 ***************************************************/

%let	study	=	�e�X�g���� (TEST study) ;
%let	sdtm	=	X:\SDTM�f�[�^\ ;
%let	outf	=	X:\�Ǘ�ꗗ�\.xlsx ;
%let	id		=	SUBJID ;			* �\������팱��ID�E�E�EUSUBJID��������SUBJID ;
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
data	mh ;
	set		mh ;
	length	mhlltx	$ 200 ;
	if	mhstdtc eq ' '	then	mhstdtc	=	'UNK' ;
	if	mhendtc eq ' '	then	mhendtc	=	'UNK' ;
	if	mhenrf eq "&MHONGO"	then
		mhlltx	=	trim ( mhllt ) || ' ' || trim ( left ( mhstdtc ) ) || ' - *' ;
	else
		mhlltx	=	trim ( mhllt ) || ' ' || trim ( left ( mhstdtc ) ) || ' -' || trim ( left ( mhendtc ) ) ;
	keep	usubjid mhlltx ;
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
	length	cmtrtx	$ 200 ;
	if	cmstdtc eq ' '	then	cmstdtc	=	'UNK' ;
	if	cmendtc eq ' '	then	cmendtc	=	'UNK' ;
	cmtrtx	=	trim ( cmtrt ) || ' (' || trim ( cmstdtc ) || '-' || trim ( cmendtc ) || ')' ;
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
			mh
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
		c1	=	&id ;
		dos	=	put ( rfxstdtc , yymmdd10. ) ;
		mht	=	mhlltx ;
		cmt	=	cmtrtx ;
		if	dthfl eq 'Y'	then	dth	=	put	( dthdtc , yymmdd10. ) ;
		else						dth	=	'ALIVE' ;
	end ;
	else do ;
		if	mhlltx eq mht	then	mhlltx	=	' ' ;
		else						mht	=	mhlltx ;
		if	cmtrtx eq cmt	then	cmtrtx	=	' ' ;
		else						cmt	=	cmtrtx ;
		l	=	l + 1 ;
		select	( l ) ;
			when	( 2 )	do ;
				c1	=	put ( age , 2. ) || ' ' || sex ;
				dos	=	put ( rfxendtc , yymmdd10. ) ;
				dth	=	ddorres ;
				end ;
			when	( 3 )	do ;
				c1	=	actarmcd ;
				dos	=	put ( rfendtc , yymmdd10. ) ;
				end ;
			when	( 4 )	do ;
				dos	=	dsterm ;
				end ;
			otherwise		c1	=	' ' ;
		end ;
	end ;
	if	last.usubjid	then	l	=	99 ;
	keep	&id	c1	mhlltx	cmtrtx	dos	dth	l ;
	label	c1		=	'�Ǘ�ԍ�*�N�� ����*���^�Q'
			mhlltx	=	'�����ǁE������'
			cmtrtx	=	'�O���Ö�'
			dos		=	'���^�J�n��*���^�I����*���~�����*���~���R'
			dth		=	'�����܂��͎��S��*���S���R'
			;
run ;
proc sort	data	=	background2 ;
	by	&id	l ;
run ;
/*
 * Excel�o��
 */
title		"&study �Ǘ�ꗗ�\" ;
footnote	'&P/&N' ;
ods	excel	file	=	"&outf"
			options ( 
				sheet_name	= '�Ǘ�ꗗ�\'
				orientation	= 'landscape'
				pages_fitwidth	=	'1'	
				pages_fitheight	=	'999'
				row_repeat		=	'1'
			) ;
proc report	data	=	background2
				split='*'
				style(report)	=	[borderwidth=1.5 bordercolor=black]
				style(header)	=	[just=c borderbottomstyle=double borderbottomcolor=black]
				;

	columns	L c1	mhlltx	cmtrtx	dos	dth DEF	;

	define	c1		/ style	=	[width=60pt just=c] ;
	define	mhlltx	/ style	=	[width=200pt] ;
	define	cmtrtx	/ style	=	[width=300pt] ;
	define	dos		/ style	=	[width=150pt] ;
	define	dth		/ style	=	[width=100pt] ;
	define	L		/ noprint ;
	define	DEF		/ noprint	computed ;

	compute	DEF ;
		if	L.sum eq 99	then
			call	define	( _row_ ,	'style' ,	"style=[borderbottomcolor=black borderbottomwidth=0.1]" ) ;
		else
			call	define	( _row_ ,	'style' ,	"style=[borderbottomcolor=white borderbottomwidth=0.5]" ) ;
	endcomp ;
run ;
ods	excel	close ;
