// =============================================
// Contact: <imaclim.r.world@gmail.com>
// Licence: AGPL-3.0
// Authors:
//     Florian Leblanc
//     (CIRED - CNRS/AgroParisTech/ENPC/EHESS/CIRAD)
// =============================================

// This file concerns fonction that create .csv of metadata of each scenarios 
// and .csv of diagnostic data
// Those files are meant to be used by the .py function <> to create a .xlsx spreadsheet of 
// a large diagnosic of each scenario run in the same folder

// extract_str_N_number: extract number and letters from a string (with letters first and numbers then)
// create_metadata_diagnos: create the metadata .csv file per scenario
// create_data_diagnos: create the data .csv file per scenario

// quick function to extract from a string letters, then number
// As Regexp is not so convenient in Scilab
function [letters,numbers] = extract_str_N_number(str)
    for i = 1:length(str)
        if isnum(part(str,i)) & part(str,i)<>'i' //strangly, scilab consider 'i' as the imaginary number
            letters = part(str,1:(i-1));
            numbers = part(str,i:length(str));
            break;
        end
    end
endfunction

// This function create a .csv wih several metadata of the scenario
function create_metadata_diagnos(outputfile, combi, outputrunname, ind_sc_names, ind_sc_values, suffix2combiName, run_date, scenario_commentary)
    // Get SVN revision number & Guess if the code has been modified
    folder="temp_"+run_name+suffix2combiName+run_date+"/"; // create a unic temporary folder
    mkdir(folder)
    svn_file_nb = folder+"svn_revision_number.txt";
    svn_file_url = folder+"svn_url.txt";
    unix_s("svn info --show-item revision > "+svn_file_nb);
    unix_s("svn info --show-item url > "+svn_file_url);
    diff_file = folder+"diff.diff";
    unix_s("svn diff > "+diff_file);
    // Wait 1 seconds to let files being created in case of a lot of input/output activities for the disk
    sleep(1000);
    if mgetl(diff_file) == []
        suffix_revision_name = "";
    else
        suffix_revision_name = "_modified";
    end
    svn_revision_nb = csvRead(svn_file_nb);
    svn_branch_name = mgetl(svn_file_url,1);
    svn_branch_name = strsplit(svn_branch_name,'/');
    svn_branch_name = svn_branch_name($);
    unix_s("rm -r "+folder) // delete temporary folder

    // Convert suffix2combiName into a vector 
    txt=strsplit(suffix2combiName,'.');
    suffix_for_metadata = [];
    for i=1:size(txt(2:$),"r")
        [nb,lt] = extract_str_N_number(txt(i+1));
        suffix_for_metadata=[suffix_for_metadata,[nb;lt]];
    end

    // Create the metadata file
    if outputrunname==[]
	outputrunname="None";
    end
    metadata_sc=[["combi";combi],["Run Name";outputrunname],["Run Time"; run_date],["Model version"; svn_branch_name + ' -r'+svn_revision_nb+suffix_revision_name]["Commentary";scenario_commentary],[ind_sc_names(2:$)';ind_sc_values],suffix_for_metadata];
    csvWrite( metadata_sc, outputfile, "|");
endfunction


// This function create a .csv wih several data of the scenario
function create_data_diagnos(outputfile,diagnotic_list,list_var2output_file)
    // get the list of variable to output
    list_var = mgetl(list_var2output_file);
    str_test=list_var(2);
    // test if the rule is to exclude some variables
    do_exclude=%f;
    if length(str_test)>7
        if part(str_test,1:7)=="EXCLUDE";
            do_exclude=%t;
        end
    end
    // do the Job: conserve ALL, exclude of select
    if do_exclude // exclude some variables
        list_2_exclude = strsplit(str_test,'|');
        list_2_exclude = list_2_exclude(2:$);
        for i=1:size(list_2_exclude,"r")
            rows=grep(diagnotic_list(:,1), list_2_exclude(i));
            if rows<>[]
                diagnotic_list(rows,:) = [];
            end
        end
    elseif list_var(2)<>"ALL" // variable selection if not all
        j=0; //  create an indices to follow the exact position of the modified diagnotic_list list
        for i=1:size(diagnotic_list,"r")
            j=j+1;
            if find( list_var(2:$) == diagnotic_list(j,1)) == []
                diagnotic_list(j,:) = [];
                j = j-1;
            end
        end
    end
    // output diagniostic variable in a file
    csvWrite( diagnotic_list', outputfile, "|");
endfunction



