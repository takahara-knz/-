/******************************************************
 * LB�h���C������Ǘᖈ�̗Ռ��l�̐��ڃO���t���쐬���� *
 * �o�͂��������̔ԍ��� LBGLPID�ɓ��͂���Ă���O��   *
 * LBGLPID���u�����N�̏ꍇ�ALBCAT+LBSPEC+LBTEST��     *
 * SDTM�t�H���_�ɁAVisitList.csv���쐬���Ă���        *
 * 			  S.Takahara Kanazawa University Hospital *
 ******************************************************/

%let	usubjid	=	TEST-0008 ;		* �o�͂�����USUBJID ;

/***** ���� *****
 �@ SDTM�f�[�^���i�[����Ă���t�H���_��sdtm�Ɋ��蓖�Ă�
 �A �o��PDF�t�@�C���̃t�H���_��outf�Ɋ��蓖�Ă�
 ****************/

%let	sdtm	=	R:\02.General\61.SAS���ʃ��W���[��\CDISC�ėpSAS�v���O����\�e�X�g�f�[�^ ;
%let	outf	=	\\DM-SERVER2\FRedirect$\takahara\Desktop ;

ods	pdf	file	=	"&outf\graph_&usubjid..pdf"  ;

options	orientation	=	landscape ;
options	mprint ;

/*
 * Visit�֘A��Format���쐬����
 */
proc import	out			=	visit_list0
				datafile	=	"&sdtm\visitlist.csv"
				dbms		=	csv
				replace
				;
	getnames		=	yes ;
	datarow			=	2 ;
	guessingrows	=	max ;
run ;
* ���Ԋu�ɐU��Ȃ���Format ;
data	visiti(rename=(l=label)) ;
	set		visit_list0 ;
	retain	l	0 ;
	l	=	l + 1 ;
	start	=	visitnum ;
	end		=	visitnum ;
	fmtname	=	'visiti' ;
	type	=	'i' ;
	keep	start	end	l	fmtname	type ;
run ;
proc format	cntlin	=	visiti ;
run ;
* �U��Ȃ������ԍ��Ƀ��x��������t�H�[�}�b�g ;
data	visitf ;
	set		visit_list0 ;
	retain	l	0 ;
	l	=	l + 1 ;
	start	=	l ;
	end		=	l ;
	fmtname	=	'visitf' ;
	type	=	'n' ;
	keep	start	end	label	fmtname	type ;
run ;
proc format	cntlin	=	visitf ;
run ;
/*
 * SDTM�f�[�^�ǂݍ���Macro
 */
%macro	readds	( domain , select ) ;
	proc import	out			=	&domain.0
				datafile	=	"&sdtm\&domain..csv"
				dbms		=	csv
				replace
				;
			getnames		=	yes ;
			datarow			=	2 ;
			guessingrows	=	max ;
	run ;
	data	&domain.1 ;
		set		&domain.0 ;
			where	&select ;
	run ;
%mend ;

/*
 * SDTM�f�[�^�ǂݍ��� ;
 */
%readds		( lb , usubjid eq "&usubjid" ) ;

data	lb2 ;
	set		lb1 ;
		where	lbstresn ne . ;				* �O���t�ɂ���̂Ő��l�f�[�^�̂� ;

	itemno		=	input	( lbgrpid ,	best. ) ;	
	visitno		=	input	( visitnum ,	visiti. ) ;		* Visitnum�𓙊Ԋu�ɐU�蒼�� ;
	keep	usubjid	lbgrpid	lbcat	lbspec	lbtest	lbstresn	lbstresu	lbstnrlo	lbstnrhi	visitno ;
	format	visitno	visitf. ;
run ;

proc sort	data	=	lb2 ;
	by	lbgrpid	lbcat	lbspec	lbtest	lbstresu	visitno ;
run ;

goptions	hby	=	2 cells ;	

symbol1	color		=	black
		value		=	dot
		width		=	8
		interpol	=	join ;
symbol2	color		=	black
		value		=	plus
		line		=	4
		interpol	=	join ;
symbol3	color		=	black
		value		=	plus
		line		=	4
		interpol	=	join ;

axis1	major	=	( number	=	1 )
		minor	=	none ;

title	"*** Laboratory Test RESULT *** USUBJID = &usubjid" ;

proc gplot	data	=	lb2 ;
	by		lbgrpid	lbcat	lbspec	lbtest lbstresu ;
	plot	lbstresn * visitno
			lbstnrlo * visitno
			lbstnrhi * visitno
			/ 	overlay
				haxis	=	axis1 ;
	format	visitno	visitf. ;
	label	lbgrpid	=	'No.'
			lbcat	=	'Cat.'
			lbspec	=	'Spec.'
			lbtest	=	'Test'
			lbstresu	=	'Unit'
			lbstresn	=	'Result'
			visitno	=	'Visit'
			;
run ;

quit ;

ods	pdf	close ;
