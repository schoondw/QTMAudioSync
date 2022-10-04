function qtm = qtm_timecode_uint64todouble(qtm,tc_field)
% function qtm = qtm_timecode_uint64todouble(qtm,tc_field)
%
% Casts values contained in structure comtaining time code (tc_field) to
% double precision.
% 
% Applies to matlab export from QTM 2.16 and higher, in which time code is
% exported as uint64. Casting to double may be needed for calculations
% based on time code (e.g. conversion to seconds with decimals).
% 
% Note that time code values may be too large to be represented by double
% precision, in particular camera time code tick values (the main reason why
% timecode is exported as uint64 by QTM). 
% 

% Read tc structure into table
tc_table=struct2table(qtm.(tc_field));
sflds=tc_table.Properties.VariableNames;

% Replace time code substructure in QTM by idem converted to double.
% Steps:
% - convert to array
% - cast to double
% - convert back to table and then to struct
qtm.(tc_field)=...
    table2struct(array2table(double(table2array(tc_table)),'VariableNames',sflds));

end

