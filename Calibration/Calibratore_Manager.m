clear
close all
clc
%persistent FileName Par_Calib Var_Calib

FileName='example1';

% Minimum % Step %Maximum
Par_Calib(1)={'a=1:0.1:6'};
% Par_Calib(2)={'c:1:0.1:6'};


%Variance
Var_Calib=[1,nan;0,1];

% Variance Weight Matrix
Var_Weight=[1,1;1,1];
%Auto Correlatoin
ACorr_Calib=[nan,nan];

% Wieght Matrix

% Steady State 
SS_Calib=[nan,nan];

% Wieght Matrix

% Weight Vector
Res=Calibratore(FileName,Par_Calib,Var_Calib,ACorr_Calib,SS_Calib);


% Clear Extra Var
clearvars -except Res