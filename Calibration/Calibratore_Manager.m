clear
close all
clc
%persistent FileName Par_Calib Var_Calib

FileName='example1';

% Minimum % Step %Maximum
Par_Calib(1)={'*=1:0.1:6'};
%Par_Calib(1)={'a=1:0.1:6'};
%Par_Calib(2)={'c:1:0.1:6'};


%Variance
Var_Calib=[1,nan;0,1];

% Variance Weight Matrix
Var_Weight=[1,1;1,1];
%Auto Correlatoin of 1 lag 
ACorr_Calib=[nan,nan;nan,nan];

% Wieght Matrix

% Steady State 
SS_Calib=[nan,nan];
% Wieght Matrix

% Steady State 
Mean_Calib=[nan,nan];
% Weight Vector

Res=Calibratore(FileName,Par_Calib,Var_Calib,ACorr_Calib,SS_Calib,Mean_Calib);


% Clear Extra Var
clearvars -except Res