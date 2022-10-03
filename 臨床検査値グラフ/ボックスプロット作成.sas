/******************************************************
 * LB�h���C������Ռ��l�̃{�b�N�X�v���b�g���쐬����   *
 * �o�͂��������̔ԍ��� LBGLPID�ɓ��͂���Ă���O��   *
 * LBGLPID���u�����N�̏ꍇ�ALBCAT+LBSPEC+LBTEST��     *
 * 			  S.Takahara Kanazawa University Hospital *
 ******************************************************/

/***** ���� *****
 �@ SDTM�f�[�^���i�[����Ă���t�H���_��sdtm�Ɋ��蓖�Ă�
 �A �o��PDF�t�@�C���̃t�H���_��outf�Ɋ��蓖�Ă�
 ****************/

%let	sdtm	=	T:\Projects\XXXX\41.Data\sdtm\csv ;
%let	outf	=	C:\Output ;

ods	pdf	file	=	"&outf\boxplot.pdf"  ;

options	orientation	=	landscape ;
options	mprint ;

proc	format ;
* VISIT �����͂���Ă��Ȃ��ꍇ�AVisit�����`���� ;
	value visitf
		-1			=	'Scr'
		0			=	'Pre'
		120			=	'120min'
		7000		=	'Day7'
	;
run ;


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
run ;
proc sgplot data	=	lb1 ;
	by		lbgrpid	lbcat	lbspec	lbtest	lbstresu ;
	vbox	lbstresn	/category	=	visitnum ;
	label	lbcat	=	'Category'
			lbspec	=	'Specimen'
			lbtest	=	'Test'
			lbstresu	=	'Unit'
			;
	format	visitnum	visitf. ;
run ;
ods	pdf	close ;
