/******************************************************
 * LB�h���C������Ռ��l�̃{�b�N�X�v���b�g���쐬����   *
 * �o�͂��������̔ԍ��� LBGLPID�ɓ��͂���Ă���O��   *
 * LBGLPID���u�����N�̏ꍇ�ALBCAT+LBSPEC+LBTEST��     *
 * SDTM�t�H���_�ɁAVisitList.csv���쐬���Ă���        *
 * 			  S.Takahara Kanazawa University Hospital *
 ******************************************************/

/***** ���� *****
 �@ SDTM�f�[�^���i�[����Ă���t�H���_��sdtm�Ɋ��蓖�Ă�
 �A �o��PDF�t�@�C���̃t�H���_��outf�Ɋ��蓖�Ă�
 ****************/

%let	sdtm	=	R:\02.General\61.SAS���ʃ��W���[��\CDISC�ėpSAS�v���O����\�e�X�g�f�[�^ ;
%let	outf	=	\\DM-SERVER2\FRedirect$\takahara\Desktop ;

ods	pdf	file	=	"&outf\boxplot.pdf"  ;

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
* Format ;
data	visitf ;
	set		visit_list0 ;
	start	=	visitnum ;
	end		=	visitnum ;
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
%readds		( lb , lbstresn ne . ) ;	* �{�b�N�X�v���b�g�Ȃ̂Ő��l�f�[�^�̂� ;

proc sort	data	=	lb1 ;
	by	lbgrpid	lbcat	lbspec	lbtest	lbstresu	visitnum ;
	format	visitnum	visitf. ;
run ;

proc sgplot data	=	lb1 ;
	by		lbgrpid	lbcat	lbspec	lbtest	lbstresu ;
	vbox	lbstresn	
			/	category	=	visitnum ;
	label	lbgrpid	=	'No.'
			lbcat	=	'Cat.'
			lbspec	=	'Spec.'
			lbtest	=	'Test'
			lbstresu	=	'Unit'
			lbstresn	=	'Result'
			visitnum	=	'Visit'
			;
	format	visitnum	visitf. ;
run ;
ods	pdf	close ;
