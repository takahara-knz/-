/****************************************************
 * SDTM�f�[�^����p��ł̗L�Q���ۈꗗ�\���쐬����   *
 * �L�Q���ۖ���MedDRA LLT-J�ŕ\������               *
 * 			S.Takahara Kanazawa University Hospital	*
 ****************************************************/

/***** ���� *****
 �@ SDTM�f�[�^���i�[����Ă���t�H���_��sdtm�Ɋ��蓖�Ă�
 �A �o��Excel�t�@�C����outf�Ɋ��蓖�Ă�
 ****************/

%let	sdtm	=	T:\Projects\XXXX\41.Data\sdtm\csv ;
%let	outf	=	C:\Output\aeliste.xls ;

options	mprint ;
options	missing	=	' ' ;
title ;

/*
 * Macro Codes
 */
* SDTM�f�[�^�ǂݍ��݁E�E�Edomain��+0�͓ǂݍ��݂��̂܂܁Adomain��+1�͑I���� ;		
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
%readds		( ae , AETERM ne '' ) ;
%readds		( dm , usubjid ne '' ) ; 

proc sort	data	=	ae1 ;	* usubjid�Ɣ������Ń\�[�g ;
	by	usubjid	aestdtc ;
run ;

proc sort	data	=	dm1 ;
	by	usubjid ;
run ;

data	ae2 ;
	merge	dm1
			ae1(in=a) ;
		by	usubjid ;
*	if	a ;				* �L�Q���۔����݂̂����X�g�ɂ���ꍇ�B�L�Q���ۂ̂Ȃ��Ǘ���uN/A�v�ƕ\��������̂ł���΁A�����̓R�����g�A�E�g ;

	keep	usubjid	age	sex	arm	
			aellt	/* aehlt	aesoc */
			aeser
			aetoxgr
			aerel
			aeout
			;

	label	usubjid		=	'Subject ID'
			age			=	'Age'
			sex			=	'Sex'
			arm			=	'Arm'
			aellt		=	'Adverse event name (LLT)'
			aeser		=	'Serious'
			aetoxgr		=	'Toxicity Grade'
			aerel		=	'Causality'
			aeout		=	'Outcome'
			;
run ;
proc sort	data	=	ae2 ;
	by	usubjid ;
run ;
/*
 * �o�͗p�f�[�^�Z�b�g
 */
data	output ;
	format	usubjid
			age	
			sex	
			arm	
			aellt
			aeser
			aetoxgr
			aerel
			aeout
			;
	set		ae2 ;
		by	usubjid ;
	if	not	first.usubjid	then	do ;
		usubjid	=	' ' ;
		age		=	' ' ;
		sex		=	' ' ;
		arm		=	' ' ;
	end ;
	if	aellt eq ' '	then	aellt	=	'N/A' ;
run ;
/*
 * Excel�\��
 */
filename	outf	"&outf" ;
ods html 	file	= 	outf
			rs		=	none
			style	=	minimal ;
proc print	data	=	output	label	noobs ;
run ;
ods	html	close ;
