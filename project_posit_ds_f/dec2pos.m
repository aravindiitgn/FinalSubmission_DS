function final =  dec2pos(dec, bitLength, expLength)
%  DEC2POS Converts a decimal to a posit.
% 
% Uses an input of a base 10 number, the posit length, and the exponent length 
% of the posit to output a char array that represents the posit.
% 
% Example: '0100101100000000' = dec2pos(7, 16, 3)
% 
% 
% 
% Decodes posits with the equation x = (-1)^sign * useed^regime * 2^exponent 
% * fraction, where useed = 2^2^exponentLength.
% 
% 
% 
% For the most accurate conversions, start at a posit length of 8 and an exponent 
% length of 0, dec2pos(x, 8, 0)
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
    i = 0;
    useed = 2^(2^expLength);
    regimeSize = 1;
    exp = 0;
    
    % special cases
    if dec == 0
        final = zeros(1, bitLength);
        final = num2str(final);
        final = final(~isspace(final));
        return
    end
    if dec == Inf
        final = zeros(1, bitLength);
        final(1) = 1;
        final = num2str(final);
        final = final(~isspace(final));
        return
    end
    if abs(dec) < 1 % tests for decimal to ensure proper method for coding bits
        
        cont = 0;
    elseif abs(dec) >= 1
        cont = 1;
    end
%% 
% Sign
% positive if first bit is 0, negative if 1
    if dec > 0
        sign = 0;
    elseif dec < 0
        sign = 1;
    end
dec = abs(dec);
    i = i + 1;
%% 
% Regime   
% if regime bits are '1', divides input by useed until less than useed
% if regime bits are '0', multiplies until dec is greater than 1
    if cont == 1
    while dec > useed
        regimeSize = regimeSize + 1;
        dec = dec/useed;
        i = i + 1;
    end
    regime = ones(1,regimeSize);
        stopBit = 0;
        i = i + 1;
    elseif cont == 0
    while dec < 1
        regimeSize = regimeSize + 1;
        dec = dec*useed;
        i = i + 1;
    end
        regime = zeros(1,regimeSize-1);
        stopBit = 1;
    end
    i = i + 1; % adds one for terminating bit
%% 
% Exponent    
% counts number of divisions until dec is less than 2, then converts
% cumulative divisions into binary
    while dec > 2
        exp = exp + 1;
        dec = dec/2;
        
    end
    i = i + expLength;
    exp = dec2bin(exp, expLength);
    expArray=zeros(1,numel(exp)); % turns char string into array
    for j=1:numel(expArray)
    expArray(j)=str2double(exp(j));
    end
    expArray = expArray(1:expLength);
    exp = num2str(expArray);
%% 
% Fraction
% uses remaining bits to add accuracy to conversion
    i = bitLength - i;
    dec = dec - 1;
    dec = dec*(2^i);
    dec = dec2bin(dec, i);
%% 
% Posit Compilation
    bitArray = [sign, regime, stopBit]; % compiles array bits
    bitString = num2str(bitArray); % turns bits into char string
    bitString = bitString(~isspace(bitString));
    exp=exp(~isspace(exp));
    dec=dec(~isspace(dec)); % turns bits into char string
    final = [bitString,exp,dec]; % compiles full char string

end