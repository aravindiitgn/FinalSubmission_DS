function final =  pos2dec(bit, bitLength, expLength)
%  POS2DEC Converts a posit to a decimal.
% 
% Uses an input of a character array, the posit length, and the exponent length 
% of the posit to output a char array that represents the posit.
% 
% Example: 7 = pos2dec('0100101100000000', 16, 3)
% 
% 
% 
% Writes posits with the equation x = (-1)^sign * useed^regime * 2^exponent 
% * fraction, where useed = 2^2^exponentLength.
% 
% 
% 
% For the most accurate conversions, start at a posit length of 8 and an exponent 
% length of 0, pos2dec(x, 8, 0)
% 
% 
% 
% Standard posits follow that for every doubling of the posit length, the exponent 
% increases by one.
% 
% <8, 0>, <16, 1>, <32, 2>...
% 
% 
% 
% For more details on posits, read <a href ="matlab:web('https://posithub.org/docs/Posits4.pdf')">this 
% paper on posit arithmetic</a>.
% 
% 
    % final = (-1)^sign * useed^regime * fraction
    % <16,3>, 16 bit posit with 3 bit exponent
    useed = 2^(2^expLength);
 
    sign = 0;
    regime = 0;
    exp = 0;
    fraction = 0;
    
    bitArray=zeros(1,numel(bit)); % turns char array into numerical array
for i=1:numel(bit)
bitArray(i)=str2double(bit(i));
end
%% 
% Sign
% positive if first bit is 0, negative if 1
if bitArray(1) == 1
    sign = 1;
end
% special cases for posits
if bitArray(2:bitLength) == zeros(1,bitLength-1)
    if sign == 0
        final = 0;
        return
        
    elseif sign == 1
        final = Inf;
        return
    end
end
%% 
% Regime
% uses second bit to determine identical regime bits
% length of regime ends when either opposite bit encountered, or 
% bitLength is reached
cont = bitArray(2);
i = 2; % reads bits as they increase
while (i < bitLength-1)
if(bitArray(i) ~= cont)
    break
end
regime = regime + 1;
i = i+1;
end
if cont == 0
    regime = -regime; % creates negative exponent for 1>x>0
elseif cont == 1
    regime = regime - 1; % subtracts 1 to allow for numbers less than useed
end
i = i+1; % adds one bit for terminating bit on regime
%% 
% Exponent
if expLength > 0
back = 2; % used to convert binary into decimal exponent
for i = i:i+expLength-1
    if(bitArray(i) == 1)
        exp = exp + 2^back;
    end
back = back - 1;
end
i = i+1;
end
%% 
% Fraction
% uses remaining bits to add accuracy to conversion
back2daFuture = bitLength-i; 
back3daFutre = 2^(back2daFuture+1);
for i = i:bitLength
    if(bitArray(i) == 1)
        fraction = fraction + 2^back2daFuture;
    end
back2daFuture = back2daFuture - 1;
end
%% 
% Posit Compilation
final = (-1)^sign*useed^regime*2^exp*(1+fraction/(back3daFutre));
end