function [] = BlackCarbon
%%%%%%%%%
% Notes %
%%%%%%%%%

% all state variables will be Capitalized
% all rate variables will be lowercased
% all methods/functions will be in camelCase


%%%%%%%%%%%%%%%%%%%%%
% Defined Variables %
%%%%%%%%%%%%%%%%%%%%%

% How many is this running for?
duration = 50; %years

% What percent of black carbon is reduced?
BC_reduction = 0; %Written in percent between 0 and 100

% Do you want graphs to show?
show = false; %true shows graphs

% Do you want to export records to Excel?
export = false; %true exports records


% Uncomment this if analyzing the effects of different BC reductions

%   percent_record = zeros(1,100);

%   for j = 1:100  

%   bc = 6.4   %percent reduction at 100% intervention
%   BC_reduction = bc*j/100;

% End uncommenting

%%%%%%%%%%%%%%%%%%%%%%%
% Recording Variables %
%%%%%%%%%%%%%%%%%%%%%%%

duration_vector = zeros(1,duration);

duration_vector(:) = 1:duration;
sea_level_record = zeros(1,duration);
sea_level_total_record = zeros(1,duration);
total_water_record = zeros(1,duration);

atmosphere_record = zeros(1,duration);
ocean_record = zeros(1,duration);
ice_record = zeros(1,duration);
soil_moisture_record = zeros(1,duration);
groundwater_record = zeros(1,duration);
permafrost_record = zeros(1,duration);
rivers_lakes_record = zeros(1,duration);
biological_record = zeros(1,duration);
land_record = zeros(1,duration);

%%%%%%%%%%%%%%%%%%
% Initial States %
%%%%%%%%%%%%%%%%%%

% Water distributions in km^3 * 10^3 
Atmosphere = 12.7;
Ocean = 1335040;
Ice = 26350;
Soil_Moisture = 122;
Groundwater = 15300;
Permafrost = 22;
Rivers_Lakes = 178;
Biological = 1.12;
Land = Soil_Moisture + Groundwater + Permafrost + Rivers_Lakes + Biological;

initial_total_water = Atmosphere + Ocean + Ice + Land;
initial_amount_of_ice = Ice;

sea_level_record(1) = 2;
sea_level_total_record(1) = 2;
total_water_record(1) = initial_total_water;

atmosphere_record(1) = Atmosphere;
ocean_record(1) = Ocean;
ice_record(1) = Ice;
soil_moisture_record(1) = Soil_Moisture;
groundwater_record(1) = Groundwater;
permafrost_record(1) = Permafrost;
rivers_lakes_record(1) = Rivers_Lakes;
biological_record(1) = Biological;
land_record(1) = Land;

%%%%%%%%%
% Rates %
%%%%%%%%%

o_evap = 0.00030935;
o_precip = o_evap * 0.9031477;
o2l_transport = o_evap * 0.0968523;
l_evap = 0.4075480125;
surface_flow = 0.7247191;
ice_exchange = 0.00002833638026;

%%%%%%%%%%%%%%
% Simulation %
%%%%%%%%%%%%%%
for year = 2:duration

    % Temporary variables to represent t-1 values
    a = Atmosphere;
    o = Ocean;
    i = Ice;
    sm = Soil_Moisture;
    g = Groundwater;
    p = Permafrost;
    rl = Rivers_Lakes;
    b = Biological;
    l = Land;

    % Update variable rates
    %   ice_exchange = getIceExchangeRate(ice_melt, ice_melt_increase);
    ice_exchange = percentReduced(BC_reduction) * ice_exchange * (1 + 0.015);
    l_precip = o*o2l_transport + (rl + b)*l_evap;

    % ODEs to update values
    Atmosphere = a - l_precip - o*o_precip + o*o_evap + (rl + b)*l_evap;
    Ocean = o*(1 - o_evap - o2l_transport) + i*ice_exchange + rl*surface_flow + o*o_precip;
    Ice = i*(1 - ice_exchange);
    Land = l - (rl + b)*l_evap - rl*surface_flow + o*o2l_transport + l_precip;
    Soil_Moisture = Land *178/15623.12;
    Groundwater = Land *22/15623.12;
    Permafrost = Land *15300/15623.12;
    Rivers_Lakes = Land *122/15623.12;
    Biological = Land *1.12/15623.12;

    % Record updated values
    sea_level_record(year) = getSeaLevel(i,Ice);
    sea_level_total_record(year) = getSeaLevel(initial_amount_of_ice,Ice);
    total_water_record(year) = Atmosphere + Ocean + Ice + Land;
    atmosphere_record(year) = Atmosphere;
    ocean_record(year) = Ocean;
    ice_record(year) = Ice;
    soil_moisture_record(year) = Soil_Moisture;
    groundwater_record(year) = Groundwater;
    permafrost_record(year) = Permafrost;
    rivers_lakes_record(year) = Rivers_Lakes;
    biological_record(year) = Biological;
    land_record(year) = Land;
end

% Uncomment this if analyzing the effects of different BC reductions

%percent_record(j) = MMtoInches(sea_level_total_record(duration));
%end

% End uncommenting

%%%%%%%%%%%
% Results %
%%%%%%%%%%%

%fprintf('The amount of water in the ocean changed from %.1f to %.1f.\n', ocean_record(1), Ocean);
%fprintf('The amount of water in the atmosphere changed from %.1f to %.1f.\n', atmosphere_record(1), Atmosphere);
%fprintf('The amount of water in the land changed from %.1f to %.1f.\n', land_record(1), Land);
%fprintf('The amount of carbon in the soil increased from %.1f Gt to %.1f Gt.\n', soil_carbon_record(1), Soil_Carbon);

fprintf('After %.f years, the sea level rose %.1f mm (%.1f inches).\n', duration, sea_level_total_record(duration), MMtoInches(sea_level_total_record(duration)));

%%%%%%%%%
% Plots %
%%%%%%%%%

if (show)
    figure
    ax3 = subplot(3,2,1);
    ax4 = subplot(3,2,2);
    ax6 = subplot(3,2,3);
    ax7 = subplot(3,2,4);
    ax8 = subplot(3,2,5);
    ax9 = subplot(3,2,6);

    x = duration_vector;

    plot(ax3,x,sea_level_record);
    title(ax3,'Sea Level Rise Per Year');

    plot(ax4,x,sea_level_total_record);
    title(ax4,'Total Rise in Sea Level');

    plot(ax6,x,atmosphere_record);
    title(ax6,'Atmosphere');

    plot(ax7,x,ocean_record);
    title(ax7,'Ocean');

    plot(ax8,x,ice_record);
    title(ax8,'Ice');

    plot(ax9,x,land_record);
    title(ax9,'Land');
end
    
    
%%%%%%%%%%%%%%%%%%%
% Export to Excel %
%%%%%%%%%%%%%%%%%%%
if (export)
    data = {
        duration_vector;
        sea_level_total_record
        };
    xlswrite('Sea Level Rise.csv',data);

    data = {
        duration_vector;
        sea_level_record
        };
    xlswrite('Seal Level Rise Average per Year.csv',data);

    data = {
        duration_vector;
        atmosphere_record
        };
    xlswrite('Atmosphere.csv',data);

    data = {
        duration_vector;
        ocean_record
        };
    xlswrite('Ocean.csv',data);

    data = {
        duration_vector;
        land_record
        };
    xlswrite('Land.csv',data);

    data = {
        duration_vector;
        ice_record
        };
    xlswrite('Ice.csv',data);

    data = {
        duration_vector;
        atmosphere_record;
        ocean_record;
        land_record;
        ice_record
        };
    xlswrite('Hydrological Budget.csv',data);
    
    % Uncomment this if analyzing the effects of different BC reductions
    %data = {
    %    1:100;
    %    percent_record
    %    };
    %xlswrite('carbon reduction.csv',data);
    % End uncommenting
    
end

end


%%%%%%%%%%%%%%%%%
% Sub-Functions %
%%%%%%%%%%%%%%%%%

function s = getSeaLevel(I,i)
    %returns rise in mm since year 0
    %i is the amount of ice for a given year
    %I is the initial amount of ice
    K = 0.068/26350000; %melting constant in km^-2
    
    s = (I-i)*K*10^9;
end

function i = MMtoInches(k)
    i = 0.0393701 * k;
end

function r = percentReduced(b)
    %returns the percent of ice melt reduced as a result of black carbon
    %reduction
    r = 1 - (.3 * b/100);
end
