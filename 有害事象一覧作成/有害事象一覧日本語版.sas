/****************************************************
 * SDTM�f�[�^������{��̗L�Q���ۈꗗ�\���쐬����   *
 * �L�Q���ۖ���MedDRA LLT-J�ŕ\������               *
 * 			S.Takahara Kanazawa University Hospital	*
 ****************************************************/

/***** ���� *****
 �@ SDTM�f�[�^���i�[����Ă���t�H���_��sdtm�Ɋ��蓖�Ă�
 �A MedDRA-J��llt-j.asc���i�[����Ă���t�H���_��MedDRAf�Ɋ��蓖�Ă�
 �B �o��Excel�t�@�C����outf�Ɋ��蓖�Ă�
 ****************/

%let	sdtm	=	T:\Projects\XXXX\41.Data\sdtm\csv ;
%let	MedDRAf	=	R:\02.General\51.�V�X�e���֘A\21.����\MedDRA 22.0\ASCII\MDRA_J220 ;
%let	outf	=	C:\Output\aelistj.xls ;

options	mprint ;
options	missing	=	' ' ;
title ;
/*
 * Formats�E�E�E�v���g�R�[����I�����ɍ��킹�ēK�X�C��
 */
Proc format ;
	value	$aeserf
		'Y'		=	'�d��'
		'N'		=	'��d��'
		;
	value	$aerelf
		'NOT RELATED'	=	'�֘A�Ȃ�'
		'RELATED'		=	'�֘A����'
		;
	value	$aeoutf
		'RECOVERED/RESOLVED'	=	'��'
		'RECOVERING/RESOLVING'	=	'�y��'
		'NOT RECOVERED/NOT RESOLVED'	=	'����'
		'RECOVERED/RESOLVED WITH SEQUELAE'	=	'���ǂ���'
		'FATAL'					=	'���S'
		'UNKNOWN'				=	'�s��'
		;
run ;

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
*	if	a ;				* �L�Q���۔����݂̂����X�g�ɂ���ꍇ�B�L�Q���ۂ̂Ȃ��Ǘ���u�����Ȃ��v�ƕ\��������̂ł���΁A�����̓R�����g�A�E�g ;
run ;

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
proc sort	data	=	ae2 ;
	by	aelltcd ;
run ;

data	ae3 ;
	merge	ae2(in=a)
			llt_j(rename=(var1=aelltcd)) ;
		by	aelltcd ;
	if	a ;
	keep	usubjid	age	sex	arm	
			aellt	/* aehlt	aesoc */
			var2
			aeser
			aetoxgr
			aerel
			aeout
			;
	rename	var2	=	AELLT_J
			;
	format	aeser	$aeserf.
			aerel	$aerelf.
			aeout	$aeoutf.
			;
	label	usubjid		=	'�o�^�ԍ�'
			age			=	'�N��'
			sex			=	'����'
			arm			=	'���t�Q'
			var2		=	'�L�Q���ۖ�(LLT)'
			aeser		=	'�d��'
			aetoxgr		=	'�ň����O���[�h'
			aerel		=	'���ʊ֌W'
			aeout		=	'�]�A'
			;
run ;
proc sort	data	=	ae3 ;
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
			aellt_j
			aeser
			aetoxgr
			aerel
			aeout
			;
	set		ae3 ;
		by	usubjid ;
	if	not	first.usubjid	then	do ;
		usubjid	=	' ' ;
		age		=	' ' ;
		sex		=	' ' ;
		arm		=	' ' ;
	end ;
	if	aellt_j eq ' '	then	aellt_j	=	'�����Ȃ�' ;
	drop	aellt ;
run ;
/*
 * Excel�\��
 */
filename	outf	"&outf" ;
ods listing close ;
ods html 	file	= 	outf
			rs		=	none
			style	=	minimal ;
proc print	data	=	output	label	noobs ;
run ;
ods	html	close ;
