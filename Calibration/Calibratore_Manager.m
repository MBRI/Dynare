clear
close all
clc
%persistent FileName Par_Calib Var_Calib

FileName='example1.mod';

% Minimum % Step %Maximum
Par_Calib(1)={'*=-6:0.1:6'};
%Par_Calib(1)={'a=-6:0.1:6'};
%Par_Calib(2)={'c:-6:0.1:6'};


%Variance
Calib.Var=[0,nan;nan,0];

% Variance Weight Matrix
Weight.Var=[1,1;1,1];
%Auto Correlatoin of 1 lag 
Calib.ACorr=[nan,nan;nan,nan];
Weight.ACorr=[1,1;1,1];
% Wieght Matrix

% Steady State 
Calib.SS=[nan,nan];
Weight.SS=[1,1];

% Wieght Matrix

% Steady State 
%Calib.Mean=[nan,nan];
Weight.Mean=[nan,nan];
% Weight Vector

Opt=Calibratore(FileName,Par_Calib,Calib);


% Clear Extra Var
clearvars -except Opt