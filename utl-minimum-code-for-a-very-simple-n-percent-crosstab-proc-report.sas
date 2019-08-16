Minimum code for a very simple n percent crosstab proc report                                                                 
                                                                                                                              
Minimum code for a very simple n percent crosstab proc report                                                                   
                                                                                                                                
 The code below creates the desired crosstab exactly.                                                                           
                                                                                                                                
 There are two 'advanced features in this code                                                                                  
                                                                                                                                
    1. Single SQL select to create bigN for each treatment column                                                               
    2. Psuedo dynamic array. Array defined at compile time.                                                                    
    3. Multiple statistics in each cell                                                                                          
                                                                                                                                
  * The report can easily be generalized for more treatment columns using macro array and do_over;                                  
                                                                                                                                                                                                                           
                                                                                                                              
Ouput report                                                                                                                  
https://tinyurl.com/yxf899fy                                                                                                  
https://github.com/rogerjdeangelis/utl-minimum-code-for-a-very-simple-n-percent-crosstab-proc-report/blob/master/grid.pdf     
                                                                                                                              
github                                                                                                                        
https://tinyurl.com/yyaaxrgp                                                                                                  
https://github.com/rogerjdeangelis/utl-minimum-code-for-a-very-simple-n-percent-crosstab-proc-report                          
                                                                                                                              
SAS Forum                                                                                                                     
https://tinyurl.com/yy8ajldh                                                                                                  
https://communities.sas.com/t5/ODS-and-Base-Reporting/Help-on-proc-report-display-frequency-count-and-percentage/m-p/579955   
                                                                                                                              
*_                   _                                                                                                        
(_)_ __  _ __  _   _| |_                                                                                                      
| | '_ \| '_ \| | | | __|                                                                                                     
| | | | | |_) | |_| | |_                                                                                                      
|_|_| |_| .__/ \__,_|\__|                                                                                                     
        |_|                                                                                                                   
;                                                                                                                             
                                                                                                                              
data have;                                                                                                                    
  input ID $  type1 $ type2 $;                                                                                                
  datalines;                                                                                                                  
  1 A1 B1                                                                                                                     
  2 A1 B2                                                                                                                     
  3 A2 B2                                                                                                                     
  4 A1 B2                                                                                                                     
  5 A2 B1                                                                                                                     
  6 A2 B1                                                                                                                     
  ;                                                                                                                           
run;                                                                                                                          
                                                                                                                              
 WORK.HAVE total obs=6                                                                                                        
                                                                                                                              
  ID    TYPE1    TYPE2                                                                                                        
                                                                                                                              
  1      A1       B1                                                                                                          
  2      A1       B2                                                                                                          
  3      A2       B2                                                                                                          
  4      A1       B2                                                                                                          
  5      A2       B1                                                                                                          
  6      A2       B1                                                                                                          
                                                                                                                              
*            _               _                                                                                                
  ___  _   _| |_ _ __  _   _| |_                                                                                              
 / _ \| | | | __| '_ \| | | | __|                                                                                             
| (_) | |_| | |_| |_) | |_| | |_                                                                                              
 \___/ \__,_|\__| .__/ \__,_|\__|                                                                                             
                |_|                                                                                                           
;                                                                                                                             
 +-------------+--------------------------+                                                                                   
 |             |           Type2          |                                                                                   
 |             |           (N=6)          |                                                                                   
 +-------------+ ------------+ ----------+                                                                                    
 |             |      B1     |      B2    |                                                                                   
 | Type1,(n/N) |    (N= 3)   |     (N= 3) |                                                                                   
 +-------------+ ------------+----------- +                                                                                   
 |     A1      |   33%(1/3)  |   67%(2/3) |                                                                                   
 +-------------+ ------------+----------- +                                                                                   
 |     A2      |   67%(2/3)  |   33%(1/3) |                                                                                   
 +-------------+-------------+------------+                                                                                   
                                                                                                                              
*          _       _   _                                                                                                      
 ___  ___ | |_   _| |_(_) ___  _ __                                                                                           
/ __|/ _ \| | | | | __| |/ _ \| '_ \                                                                                          
\__ \ (_) | | |_| | |_| | (_) | | | |                                                                                         
|___/\___/|_|\__,_|\__|_|\___/|_| |_|                                                                                         
                                                                                                                              
;                                                                                                                             
                                                                                                                              
proc sql;                                                                                                                     
    select resolve(catx(" ",'%Let',type2,'=',type2,'#(N=',Put(Count(id),4.),');'))                                            
         from have  Group by type2                                                                                            
;quit;                                                                                                                        
                                                                                                                              
/*                                                                                                                            
%put &=b1;                                                                                                                    
%put &=b2;                                                                                                                    
                                                                                                                              
B1=B1 #(N= 3 )                                                                                                                
B2=B2 #(N= 3 )                                                                                                                
*/                                                                                                                            
                                                                                                                              
ods exclude all;                                                                                                              
ods output observed=wantcnt ;                                                                                                 
proc corresp data=have dim=1 observed missing all print=both;;                                                                
tables type1, type2;                                                                                                          
run;quit;                                                                                                                     
ods select all;                                                                                                               
                                                                                                                              
/*                                                                                                                            
WORK.WANTCNT total obs=3                                                                                                      
                                                                                                                              
  LABEL    B1    B2    SUM                                                                                                    
                                                                                                                              
   A1       1     2     3                                                                                                     
   A2       2     1     3                                                                                                     
   Sum      3     3     6                                                                                                     
*/                                                                                                                            
                                                                                                                              
* put multiple stats in one cell;                                                                                             
data havCntPct/view=havCntPct;                                                                                                
                                                                                                                              
  if _n_=0 then do;%let rc=%sysfunc(dosubl('                                                                                  
                                                                                                                              
     data _null_;                                                                                                             
         set wantcnt;                                                                                                         
         array nums[*] _numeric_;                                                                                             
         call symputx("dims",dim(nums)-1);                                                                                    
     run;quit;                                                                                                                
     '));                                                                                                                     
     array chrs[&dims] $26 c1-c&dims;                                                                                         
  end;                                                                                                                        
                                                                                                                              
  set wantCnt(where=(label="Sum"))                                                                                            
      wantCnt                                                                                                                 
  ;                                                                                                                           
                                                                                                                              
  if _n_=1 then call symputx('type2',cats('Type2 # (N=',put(sum,1.),')'));                                                    
                                                                                                                              
  array cnts _numeric_;                                                                                                       
  do _i_=1 to dim(cnts)-1;                                                                                                    
    chrs[_i_]=cats(put(100*cnts[_i_]/sum,5.),'%(',cnts[_i_],'/',sum,')');                                                     
    put chrs[_i_]=;                                                                                                           
  end;                                                                                                                        
                                                                                                                              
  if label ne "Sum";                                                                                                          
  keep label c:;                                                                                                              
run;quit;                                                                                                                     
                                                                                                                              
/*                                                                                                                            
WORK.HAVCNTPCT total obs=2                                                                                                    
                                                                                                                              
 LABEL      C1          C2                                                                                                    
                                                                                                                              
  A1     33%(1/3)    67%(2/3)                                                                                                 
  A2     67%(2/3)    33%(1/3)                                                                                                 
                                                                                                                              
%put &=type2;                                                                                                                 
                                                                                                                              
TYPE2=Type2 # (N=6)                                                                                                           
*/                                                                                                                            
                                                                                                                              
ods pdf file="d:/pdf/grid.pdf";                                                                                               
proc report data=havCntPct missing nowd split='#';                                                                            
cols label ( "&type2" c1 c2 );                                                                                                
define label / "Type1,(n/N)" center;                                                                                          
define c1 / "&b1" center;                                                                                                     
define c2 / "&b2" center;                                                                                                     
run;quit;                                                                                                                     
ods pdf close;                                                                                                                
                                                                                                                              
