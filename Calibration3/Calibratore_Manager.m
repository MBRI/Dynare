clear
close all
clc
%persistent FileName Par_Calib Var_Calib

FileName='example1.mod';

% Minimum % Step %Maximum
Par_Calib(1)={'*=-100:100'};
%Par_Calib(1)={'a=-6:6'};
%Par_Calib(2)={'c:-6:6'};

% Calib=  an Structure Like oo_
% just create fiels do you wnat to be considered in calibration
% use nan for unimporatant values
load('input\C3.mat')
%Calib.var=[1,nan;nan,1];
%Calib.autocorr{1,1}=[nan,nan;nan,nan];
%Calib.autocorr{1,2}=[nan,nan;nan,nan];

% Weight=  an Structure Like oo_
load('input\W.mat')
%Weight.autocorr{1,1}=[0,0;0,0];
%Weight.autocorr{1,2}=[0,0;0,0];
% Maximum Itration
MaxIt=5000;
%Opt=
Calibratore(FileName,Par_Calib,Calib,Weight,MaxIt);
% Clear Extra Var
%clearvars -except Opt