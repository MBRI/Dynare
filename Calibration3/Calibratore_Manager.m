clear
close all
clc
%persistent FileName Par_Calib Var_Calib

FileName='example0.mod';

% Minimum % Step %Maximum
Par_Calib(1)={'*=-100:100'};
%Par_Calib(1)={'a=-6:6'};
%Par_Calib(2)={'c:-6:6'};

% Calib=  an Structure Like oo_
Calib.var=0;
%Calib.Var=[1,nan;nan,1];


% Weight=  an Structure Like oo_
Weight.var=0;
% Maximum Itration
MaxIt=300;
%Opt=
Calibratore(FileName,Par_Calib,Calib,Weight,MaxIt);
% Clear Extra Var
%clearvars -except Opt