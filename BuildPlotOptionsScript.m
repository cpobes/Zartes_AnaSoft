function opt=BuildPlotOptionsScript()
%%%podemos ir creando diferentes estilos y llamar a la función con el
%%%estilo que necesitemos en cada llamada.

%%%list of propertiy names:
%names={'Color' 'LineStyle' 'LineWidth' 'Marker' 'MarkerSize' 'MarkerEdgeColor' 'MarkerFaceColor'};
lineColors = {[0,0,1];[1,0,0];[0,0.5,0];[0,0,0];[1,1,0];[1,0,1];[0,1,1];[0.5 0.5 0.5]};

style='8transitionswithfit';
if strcmp(style,'8transitionswithfit')
lineWidthArray([1:16],1)={2};
lineColorArray([1 3],1)=lineColors(1);
lineColorArray([2 4],1)=lineColors(2);
lineColorArray([5 7],1)=lineColors(3);
lineColorArray([6 8],1)=lineColors(4);
lineColorArray([9 11],1)=lineColors(5);
lineColorArray([10 12],1)=lineColors(6);
lineColorArray([13 15],1)=lineColors(7);
lineColorArray([14 16],1)=lineColors(8);
lineStyleArray([1 2 5 6 9 10 13 14],1)={'none'};
lineStyleArray([3 4 7 8 11 12 15 16],1)={'-'};

MarkerArray([1 2 5 6 9 10 13 14],1)={'.'};
MarkerArray([3 4 7 8 11 12 15 16],1)={'none'};
MarkerSizeArray([1:16],1)={15};
MarkerEdgeColorArray={};
MarkerFaceColorArray={};

displaynameArray([1 2 5 6 9 10 13 14],1)={'R1';'R2';'L1';'L2';'R3';'R4';'L3';'L4'};
displaynameArray([3 4 7 8 11 12 15 16],1)={'fitR1';'fitR2';'fitL1';'fitL2';'fitR3';'fitR4';'fitL3';'fitL4'};

opt.names={'Color' 'LineStyle' 'LineWidth'  'MarkerSize' 'displayname'};
opt.values=[lineColorArray lineStyleArray lineWidthArray MarkerSizeArray displaynameArray];
end
%opt.names={'Color' 'LineStyle' 'LineWidth'  'MarkerSize' 'displayname'};
%opt.values=[lineColorArray lineStyleArray lineWidthArray MarkerSizeArray];