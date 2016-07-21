clear
close all
clc
%persistent FileName Par_Calib Var_Calib

FileName='example0.mod';

% Minimum % Step %Maximum
Par_Calib(1)={'*=-10:10'};
%Par_Calib(1)={'a=-6:6'};
%Par_Calib(2)={'b:-6:6'};

% Calib=  an Structure Like oo_
% just create fiels do you wnat to be considered in calibration
% use nan for unimporatant values
load('input\C4.mat')
%Calib.var=[1,nan;nan,1];
%Calib.autocorr{1,1}=[nan,nan;nan,nan];
%Calib.autocorr{1,2}=[nan,nan;nan,nan];
%Include_exo_var=1;
ex_Calib(1)={'*=0:1'};
% Weight=  an Structure Like oo_
load('input\W.mat')
%Weight.autocorr{1,1}=[0,0;0,0];
%Weight.autocorr{1,2}=[0,0;0,0];
% Maximum Itration
MaxIt=10000;
%Opt=
Calibratore(FileName,Par_Calib,ex_Calib,Calib,Weight,MaxIt);
% Clear Extra Var
%clearvars -except Opt