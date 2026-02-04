// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Ruben Bibas
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

function [matValue,matString] = csvread(str)

    if argn(1) == 1
        matValue = evstr(read_csv(str,";"));
    else
        matString = read_csv(str,";");
        matValue  = evstr(matString(strstr(matString(:,1),"//")=="",:));
        matString = strsubst(matString(~strstr(matString(:,1),"//")=="",:),"//","");
    end

endfunction

function writecsv(mat,fileName,offset)
    if ~isdef("offset")
        offset=0;
    end
    nbYear = endYear - startYear ;
    subset = (startYear:endYear) - startYear + 1 + offset;
    write_csv(strsubst(string([startYear:endYear;mat(:,subset)]),'D','e'),CSVDIR+fileName+".csv",";",".");
endfunction

function rawwritecsv(mat,fileName)
    write_csv(strsubst(string(mat),'D','e'),CSVDIR+fileName+".csv",";",".");
endfunction

function mat2latex(mat,fileName,titleRow)
    [nRaw,nCol] = size(mat);
    latexMat = strsubst(string(mat),'D','e');
    latexMat = [ latexMat(:,1:$-1) + "&" , latexMat(:,$)+"\\\hline"];
    outLatex = emptystr(nRaw+2,1);
    if argn(2) < 3
        outLatex(1,:) = "\begin{tabular}{ | "+strcat(repmat("c | ",1,nCol))+"}\hline";
    else
        titleCat = [ titleRow(:,1:$-1) + "&" , titleRow(:,$)+"\\\hline"];
        outLatex(1,:) = "\begin{tabular}{ | "+strcat(repmat("c | ",1,nCol))+"}\hline "+strcat(titleCat)
    end

for linNb = 1:nRaw
        outLatex(linNb+1,1) = strcat(latexMat(linNb,:));
    end
    outLatex(nRaw+2) = "\end{tabular}";
    fd = mopen(CSVDIR+fileName,"w");
    mfprintf(fd,"%s\n",outLatex);
    mclose(fd);
endfunction

function writecsvReg(inputVar,varname)
    for k = 1:reg
        fileName = varname+regnames(k);
        mat = squeeze(inputVar(k,:,:));
        writecsv(mat,fileName);
    end
endfunction

function writecsvSec(inputVar,varname)
    for sector = 1:sec
        mat = squeeze(inputVar(:,sector,:));
        writecsv(mat,varname+"-"+secnames(sector));
    end
endfunction
