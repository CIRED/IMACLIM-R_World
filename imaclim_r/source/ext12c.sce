//Compiles ext_imaclim.c and produces a dynamic library (so or dll). This works on linux and windows with no problem

warning("Using deprecated function to compile, thanks to definition of __USE_DEPRECATED_STACK_FUNCTIONS__");
warning("Old API will be removed after scilab 6.0");

//cleans temporary and dll
if isfile("cleaner.sce")
    exec "cleaner.sce"
end

//if ~haveacompiler() & MSDOS
//    disp("no compiler detected. maybe mingw did not load. trying again")
//    disp("break this loop if you do not have a compiler")
//    unix("start """" """+SCI+"/bin/Scilex.exe"" -e ""exec(""ext12c.sce"");quit""")
//    quit
//end

// builder code for ext12c.c 
link_name = ["allocate_matrix","set_param","set_paramX","economyC","economyXC","fill_2d_matrix"]; // functions to be added to the call table 
flag  = "c";		 // ext12c is a C function 
files = ["ext_imaclim.c"];   // objects files for ext12c 
libs  = [];		 // other libs needed for linking 

// the next call generates files (Makelib,loader.sce) used
// for compiling and loading ext12c and performs the compilation
//this is linux and windows friendly

//ilib_for_link(names,files,libs,flag [,makename [,loadername [,libname [,ldflags [,cflags [,fflags [,cc]]]]]]])
ilib_for_link(link_name,files,libs,flag,"","","","","-O2");

deletefile("ext_imaclim.o");
deletefile("liballocate_matrix.a");
