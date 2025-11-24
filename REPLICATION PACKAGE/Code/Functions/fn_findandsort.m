function [sorted_rankings] = fn_findandsort(common, array,colnum) 


   [C,ia,ib]= intersect(common,array(:,1),'rows'); 
   for i = 1:size(ib,1)
       data = array(ib,:);
   end

data1 = sortrows(data,colnum); 
ranking_num = 1:size(data1,1); 
ranking_num = ranking_num';
rankings = [data1(:,1),ranking_num];
sorted_rankings = sortrows(rankings,1); 

end 
