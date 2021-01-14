#imports
#region
import pandas as pd
import pyodbc, urllib
import io
import requests
import pandas as pd
import numpy as np
#import seaborn as sns
#import matplotlib.pylab as plt
import requests
from bs4 import BeautifulSoup
import urllib.request
from selenium import webdriver
import time
from time import sleep
import os
from sqlalchemy import create_engine
#from tqdm.notebook import tqdm, trange
from webdriver_manager.chrome import ChromeDriverManager
import csv
import datetime
from selenium import webdriver
from selenium.webdriver import ActionChains
from selenium.webdriver.common.keys import Keys
#test
#endregion


#set up some datetime parms
#Pason exports 10 second data every 10 minutes
#This allows for near-realtime. Looking back 1 minute ago, to 10 minutes ago
now = datetime.datetime.now()
now_minus_5 = now - datetime.timedelta(minutes = 1)
now_minus_15 = now - datetime.timedelta(minutes = 20)


#zfill adds leading zero for single digit month/day/hour/minute values
(to_year,to_month,to_day,to_hour,to_minute) = (str(now_minus_5.year).zfill(2),str(now_minus_5.month).zfill(2),str(now_minus_5.day).zfill(2),str(now_minus_5.hour).zfill(2),str(now_minus_5.minute).zfill(2))
(from_year,from_month,from_day,from_hour,from_minute) = (str(now_minus_15.year).zfill(2),str(now_minus_15.month).zfill(2),str(now_minus_15.day).zfill(2),str(now_minus_15.hour).zfill(2),str(now_minus_15.minute).zfill(2))


#Hsandle Pason Administrative stuff and logins
def make_scraper(headless=False):
    options = webdriver.ChromeOptions()
    if headless: 
        options.add_argument('headless')
    chromedriver = "S:\\North_Rockies\\Jonah\\GIS\\GIS_V2\\Web Scraping For Land\\Scripts\\Driver\\chromedriver.exe" 
    scraper = webdriver.Chrome(executable_path=chromedriver, options=options)
    return scraper

def login_to_pason(scraper):

    url = 'https://hub.us.pason.com/home'
    scraper.get(url)
    
    un='burgett'
    pw='FishTree594356'

    elements = scraper.find_elements_by_id('username')
    username = elements[0]
    username.clear()
    username.send_keys(un)

    elements = scraper.find_elements_by_id('password')
    password = elements[0]
    password.clear()
    password.send_keys(pw)

    elements = scraper.find_elements_by_id('login-submit-button')
    submit = elements[0]
    submit.click()

def get_active_well_numbers(scraper): 
    #get list of active wells
    url = 'https://hub.us.pason.com/search/search?SID__=&fn=process&county_selected_picklist=county_all&status=drilling&operator=1412173539'
    scraper.get(url)

    # sleep to allow js to load
    sleep(1)

    #grab actively drilling Pason well numbers
    df = pd.read_html(scraper.page_source)[0]
    active_wells=df['Well Name'].values.tolist()

    links = []
    for well in active_wells: 
        try: 
            _href = scraper.find_elements_by_link_text(well)
            link = _href[0].get_attribute('href')
            links.append(link)
        except: 
            links.append(None)
            continue
    wellnums = [link[link.find('&num=')+5:] if link != None else None for link in links ]
    df['pason_well_number'] = wellnums
    df['pason_url'] = links
    
    #return wellnums of active wells so we can generate URLs in the next function
    wellnumList = []
    for wellnum in wellnums:
        wellnumList.append(wellnum)
        
    return wellnums


#Get 3 DFs we need
def get_pason_live_df(scraper, well_numbers):
    for well_number in well_numbers:
        #go to url, get the raw source text that the webpage displays, transform it into a pandas dataframe
        scrapeURL = 'https://hub.us.pason.com/drilling_data/view/26814945.csv?igraph_template_id=302645&las_template_id=364625&pdf_template_id=302646&lrv_template_id=302648&active_template_id=364625&tab=text_download&from_date='+from_year+'%2F'+from_month+'%2F'+from_day+'&from_time=0'+from_hour+'%3A'+from_minute+'&to_date='+to_year+'%2F'+to_month+'%2F'+to_day+'&to_time=0'+to_hour+'%3A'+to_minute+'&from_depth=&to_depth=&traces_table_length=20&type=time&las_type=time&text_fmt=csv&depth_unit=imperial&show_memos=off&ignore_bit=off&checkbox_all_params=on&all_params=on&checkbox_dir_survey=on&dir_survey=on&checkbox_show_units=on&show_units=on&checkbox_omit_duplicate_depth=on&omit_duplicate_depth=on&template_id=364625'
        scraper.get(scrapeURL) 
        sleep(1)
        #use beatiful soup to get the source data copied into pandas df
        _source=scraper.page_source
        soup = BeautifulSoup(_source, features="lxml")
        payload = soup.find('body').text
        lines = payload.splitlines()
        reader = csv.reader(lines)
        parsed_csv = list(reader)
        
        #set columns that we need to use, this is the list we will keep, others we will delete       
        groomed_cols_rigdata = ['axial_vibration__no_unit_',
            'azimuth__degrees_',
            'bit_depth__feet_',
            'bit_rpm__rpm_',
            'bit_torque__kft_lb_',
            'c1_methane_gas__percent_',
            'c2_ethane_gas__percent_',
            'c3_propane_gas__percent_',
            'c4_butane_gas__percent_',
            'c5_pentane_gas__percent_',
            'casing_pressure__psi_',
            'co2_carbon_dioxide_gas__percent_',
            'convertible_torque__kft_lb_',
            'depth_of_cut__in_',
            'differential_pressure__psi_',
            'edge_ad_diff_p_sp__no_unit_',
            'edge_ad_torque_limit__no_unit_',
            'edge_adr_or_reamer_status__none___no_unit_',
            'edge_bit_rpm__fps_units_',
            'edge_diff_p__no_unit_',
            'edge_hookload__no_unit_',
            'edge_osc_tq_sp__no_unit_',
            'edge_pump_pressure__no_unit_',
            'edge_quill_osc_stat__none___no_unit_',
            'edge_rop_instant__no_unit_',
            'edge_rop_sp__no_unit_',
            'edge_stick_slip_percent__no_unit_',
            'edge_tds_rpm__no_unit_',
            'edge_tds_rpm_sp__no_unit_',
            'edge_torque__units___no_unit_',
            'edge_wob__no_unit_',
            'edr_instantaneous_rop__ft_per_hr_',
            'gamma__api_',
            'gamma_at_bit__api_',
            'h2s__ppm_gas_',
            #'hh_mm_ss',
            'hole_depth__feet_',
            'hole_diameter__in_',
            'hook_load__klbs_',
            'ic4_isobutane_gas__percent_',
            'in_slip__unitless_',
            'inclination__degrees_',
            'lat_vibration__no_unit_',
            'mechanical_specific_energy__ksi_',
            'motor_rpm__rpm_',
            'mwd_dynamic_azi__degrees_',
            'mwd_dynamic_inc__degrees_',
            'mwd_shock__no_unit_',
            'nc4_normal_butane_gas__percent_',
            'on_bottom__unitless_',
            'on_bottom_hours__hrs_',
            'on_bottom_rop__ft_per_hr_',
            'over_pull__klbs_',
            'overall_rop__ft_per_hr_',
            'pason_gas__percent_',
            'pason_gas_percent_unlagged__percent_',
            'pason_gas_unlagged__percent_',
            'pump_total_strokes_rate__spm_',
            'pvt_total_mud_gain_per_loss__barrels_',
            'rate_of_penetration__ft_per_hr_',
            'res1_at_bit__ohm_m_',
            'rig_sub_state__unitless_',
            'rig_super_state__unitless_',
            'rotary_rpm__rpm_',
            'rotary_torque__unitless_',
            'sandline_depth__feet_',
            'speed_flow_ratio__rev_per_gal_',
            'standpipe_pressure__psi_',
            'stick_slip__no_unit_',
            'surface_stick_slip_index__percent_',
            'total_mud_volume__barrels_',
            'total_pump_output__gal_per_min_',
            'trip_speed__ft_per_min_',
            'true_vertical_depth__feet_',
            'weight_on_bit__klbs_',
            #'YYYY_MM_DD',
            'Record_Time',
            'pason_well_number']
        
        #strip index row of columns, set column name headers
        #some of this might be unnecessary
        pason_live_df = pd.DataFrame(parsed_csv)
        headers = pason_live_df.loc[0]
        pason_live_df.columns = headers
        pason_live_df=pason_live_df[1:].reset_index(drop=True)
        
        index_w_none_values = pason_live_df[pason_live_df['YYYY/MM/DD'].isna()].index[0]
        pason_live_df=pason_live_df.drop(index_w_none_values)

        #groom data columns - remove protected chars, set all to lowercase, transform date data
        pason_live_df.columns = [i.lower() for i in pason_live_df.columns]
        pason_live_df.columns = pason_live_df.columns.str.replace(' ', '_').str.replace('(', '_').str.replace(')', '_').str.replace('+', '_').str.replace('-', '_').str.replace('#', '_').str.replace('/', '_per_').str.replace(':', '_').str.replace('%', 'percent')

        #add columns to datframe which are in the list of columns that we want, but are not there currently. Set NULLS to those columns where no data is present
        for col in groomed_cols_rigdata:
            if col not in pason_live_df.columns:
                pason_live_df[col] = np.nan
        
        #set well number
        pason_live_df['pason_well_number']=well_number
        #merge time fields
        pason_live_df["Record_Time"] = pason_live_df["yyyy_per_mm_per_dd"] + " " + pason_live_df["hh_mm_ss"]
        #keep only the columns that we want
        pason_live_df=pason_live_df[groomed_cols_rigdata]
                                                                                                       

        return pason_live_df

def get_well_header_df(scraper): 
    url = 'https://hub.us.pason.com/search/search?SID__=&fn=process&county_selected_picklist=county_all&status=drilling&operator=all&fieldedr0=edr&rig_combo=0&region=all&county_all=all&county_ak=all&county_al=all&county_ar=all&county_as=all&county_az=all&county_ca=all&county_co=all&county_ct=all&county_dc=all&county_de=all&county_fl=all&county_fm=all&county_ga=all&county_gu=all&county_hi=all&county_ia=all&county_id=all&county_il=all&county_in=all&county_ks=all&county_ky=all&county_la=all&county_ma=all&county_md=all&county_me=all&county_mh=all&county_mi=all&county_mn=all&county_mo=all&county_mp=all&county_ms=all&county_mt=all&county_nc=all&county_nd=all&county_ne=all&county_nh=all&county_nj=all&county_nm=all&county_nv=all&county_ny=all&county_oh=all&county_ok=all&county_or=all&county_pa=all&county_pr=all&county_pw=all&county_ri=all&county_sc=all&county_sd=all&county_tn=all&county_tx=all&county_ut=all&county_va=all&county_vi=all&county_vt=all&county_wa=all&county_wi=all&county_wv=all&county_wy=all&name='
    scraper.get(url)
    # sleep to allow js to load
    sleep(2)

    df = pd.read_html(scraper.page_source)[0]

    wells=df['Well Name'].values.tolist()

    links = []
    for well in wells: 
        try: 
            _href = scraper.find_elements_by_link_text(well)
            link = _href[0].get_attribute('href')
            links.append(link)
        except: 
            links.append(None)
            continue
    wellnums = [link[link.find('&num=')+5:] if link != None else None for link in links ]
    df['pason_well_number'] = wellnums
    df['pason_url'] = links
    df['well_type']=['H' if i[-1]=='H' else 'V'  for i in df['Well Name']]

    if 'Unnamed: 0' in df.columns:
        df=df.drop('Unnamed: 0', axis=1)
        
    return df

def get_bit_report_df(scraper, well_numbers):
    for well in well_numbers: 
        url = 'https://hub.us.pason.com/hub/cgi/bit.py?num='
        scraper.get(url+well)
        _source = scraper.page_source
        _bit_tables = pd.read_html(_source)
        bit_report = [i for i in _bit_tables if 'ROP' in i.columns ][0]
        bit_report['Depth In Calc'] = bit_report['Depth Out'] - bit_report['Depth Drilled']
        bit_report['pason_well_number']=well
        bit_report.columns = bit_report.columns.str.replace(' ', '_').str.replace('(', '_').str.replace(')', '_').str.replace('+', '_').str.replace('-', '_').str.replace('#', '_').str.replace('/', '_per_').str.replace(':', '_').str.replace('%', 'percent')
        return bit_report
        


#Write to SQL
def insert_SQL(pason_live_df,well_numbers,well_header_df,bit_report_df):
    #Connect to the ODSSQL Server and insert data into db
    server = 'SpatialSQL'
    database = 'DrillingAnalysis'
    schema = 'Stage'
    
    quoted = urllib.parse.quote_plus("DRIVER={SQL Server Native Client 11.0};SERVER="+server+";DATABASE="+database+";Trusted_Connection=yes")
    engine = create_engine("mssql+pyodbc:///?odbc_connect={}".format(quoted))

    pason_live_df=pason_live_df.replace('-999.25', np.nan)
    well_header_df['Depth']=np.nan

    #Write out to the db using the engine created above. Trusted connection is critical, must be signed on as SVC_GIS
    pason_live_df.to_sql('Pason_Live', con = engine, schema=schema, if_exists='append', index=False, index_label=None)
    well_header_df.to_sql('Well_Header', con = engine, schema=schema, if_exists='append', index=False, index_label=None)
    bit_report_df.to_sql(name='active_well_bit_reports',con=engine, schema=schema, if_exists='replace',index=True)



    #Use a different connection engine to perform a new 
    cnxn = pyodbc.connect('DRIVER={SQL Server Native Client 11.0};SERVER='+server+';DATABASE='+database+';trusted_connection=yes;unicode_results: False',autocommit=True)
    
    for well in well_numbers:
        
        #Pason Live
        stmt = ("""
          WITH CTE AS(
            SELECT pason_well_number,Record_time, 
                RN = ROW_NUMBER()OVER(PARTITION BY pason_well_number,Record_time ORDER BY Record_time)
                FROM [DrillingAnalysis].[Stage].[Pason_Live]

				)
                delete  FROM CTE WHERE RN > 1 and pason_well_number = '"""+well+"""' --order by Record_Time asc


        
        """)
        cursor = cnxn.cursor()
        cursor.execute(stmt)
        cnxn.commit()


        #Well Header
        stmt = ("""
          WITH CTE AS(
            SELECT pason_well_number, Status,
                RN = ROW_NUMBER()OVER(PARTITION BY pason_well_number,Rig ORDER BY Spud)
                FROM [DrillingAnalysis].[Stage].[Well_Header]

				)
                delete FROM CTE WHERE RN > 1 --and pason_well_number = '"""+well+"""' --order by Record_Time asc


        
        """)

        cursor = cnxn.cursor()
        cursor.execute(stmt)
        cnxn.commit()

def mergeSQL():
    #Merging SQL From stage tables into DBO Master tables

    #Connect to the ODSSQL Server and insert data into db
    server = 'SpatialSQL'
    database = 'DrillingAnalysis'
    

    cnxn = pyodbc.connect('DRIVER={SQL Server Native Client 11.0};SERVER='+server+';DATABASE='+database+';trusted_connection=yes;unicode_results: False',autocommit=True)
    
    #Pason Live
    stmt = ("""

        insert into [DrillingAnalysis].dbo.[Pason_Live]
        SELECT [axial_vibration__no_unit_]
            ,[azimuth__degrees_]
            ,[bit_depth__feet_]
            ,[bit_rpm__rpm_]
            ,[bit_torque__kft_lb_]
            ,[c1_methane_gas__percent_]
            ,[c2_ethane_gas__percent_]
            ,[c3_propane_gas__percent_]
            ,[c4_butane_gas__percent_]
            ,[c5_pentane_gas__percent_]
            ,[casing_pressure__psi_]
            ,[co2_carbon_dioxide_gas__percent_]
            ,[convertible_torque__kft_lb_]
            ,[depth_of_cut__in_]
            ,[differential_pressure__psi_]
            ,[edge_ad_diff_p_sp__no_unit_]
            ,[edge_ad_torque_limit__no_unit_]
            ,[edge_adr_or_reamer_status__none___no_unit_]
            ,[edge_bit_rpm__fps_units_]
            ,[edge_diff_p__no_unit_]
            ,[edge_hookload__no_unit_]
            ,[edge_osc_tq_sp__no_unit_]
            ,[edge_pump_pressure__no_unit_]
            ,[edge_quill_osc_stat__none___no_unit_]
            ,[edge_rop_instant__no_unit_]
            ,[edge_rop_sp__no_unit_]
            ,[edge_stick_slip_percent__no_unit_]
            ,[edge_tds_rpm__no_unit_]
            ,[edge_tds_rpm_sp__no_unit_]
            ,[edge_torque__units___no_unit_]
            ,[edge_wob__no_unit_]
            ,[edr_instantaneous_rop__ft_per_hr_]
            ,[gamma__api_]
            ,[gamma_at_bit__api_]
            ,[h2s__ppm_gas_]
            ,[hole_depth__feet_]
            ,[hole_diameter__in_]
            ,[hook_load__klbs_]
            ,[ic4_isobutane_gas__percent_]
            ,[in_slip__unitless_]
            ,[inclination__degrees_]
            ,[lat_vibration__no_unit_]
            ,[mechanical_specific_energy__ksi_]
            ,[motor_rpm__rpm_]
            ,[mwd_dynamic_azi__degrees_]
            ,[mwd_dynamic_inc__degrees_]
            ,[mwd_shock__no_unit_]
            ,[nc4_normal_butane_gas__percent_]
            ,[on_bottom__unitless_]
            ,[on_bottom_hours__hrs_]
            ,[on_bottom_rop__ft_per_hr_]
            ,[over_pull__klbs_]
            ,[overall_rop__ft_per_hr_]
            ,[pason_gas__percent_]
            ,[pason_gas_percent_unlagged__percent_]
            ,[pason_gas_unlagged__percent_]
            ,[pump_total_strokes_rate__spm_]
            ,[pvt_total_mud_gain_per_loss__barrels_]
            ,[rate_of_penetration__ft_per_hr_]
            ,[res1_at_bit__ohm_m_]
            ,[rig_sub_state__unitless_]
            ,[rig_super_state__unitless_]
            ,[rotary_rpm__rpm_]
            ,[rotary_torque__unitless_]
            ,[sandline_depth__feet_]
            ,[speed_flow_ratio__rev_per_gal_]
            ,[standpipe_pressure__psi_]
            ,[stick_slip__no_unit_]
            ,[surface_stick_slip_index__percent_]
            ,[total_mud_volume__barrels_]
            ,[total_pump_output__gal_per_min_]
            ,[trip_speed__ft_per_min_]
            ,[true_vertical_depth__feet_]
            ,[weight_on_bit__klbs_]
            ,[pason_well_number]
            ,[Record_Time]
            
        FROM (
            select a.*,b.pason_well_number as main_PWN
            from [DrillingAnalysis].stage.[Pason_Live] a
            left join [DrillingAnalysis].dbo.[Pason_Live] b
            on a.[pason_well_number] = b.[pason_well_number]
            and a.[Record_Time] = b.[Record_Time]
            )z
        WHERE main_PWN is null

        
        """)

    cursor = cnxn.cursor()
    cursor.execute(stmt)
    cnxn.commit()

    #Well Header

    stmt = ("""
    
        --Basically a test table environment
        --SELECT * INTO #DBOWELLHEADER FROM DrillingAnalysis.DBO.Well_Header



        --set everything in the dbo.well_header table that is also not in the stage table to Completed/Well Ended, basically not drilling
        --This will basically truncate active wells, only keeping wells that are done drilling
        --there are only active wells contained in the stage table, so every well in dbo.well_header will be categorized as done drilling, then we add in active wells in step 2
        update DrillingAnalysis.DBO.Well_Header
        SET [Status] = 'Completed'
        ,[Pason Live] = 'Well Ended'
        from DrillingAnalysis.DBO.Well_Header a
        left outer join [DrillingAnalysis].[Stage].[Well_Header] b
        on a.[pason_well_number] = b.Status
        and b.Status IS NULL

        --join to the stage table and copy over the stage table data into the live dbo.well_header table
        --stage table will only contain actively drilling wells
        update DrillingAnalysis.DBO.Well_Header
        SET [Status] = a.Status
        ,[Rig] = a.Rig
        ,[Well Name] = a.[Well Name]
        ,[AFE] = a.AFE
        ,[Spud] = a.Spud
        ,[Day] = a.Day
        ,[Depth] = a.Depth
        ,[Drilled] = a.Drilled
        ,[Tour] = a.Tour
        ,[EDR] = a.EDR
        ,[Pason Live] = a.[Pason Live]
        ,[Trip Sheet] = a.[Trip Sheet]
        ,[pason_well_number] = a.pason_well_number
        ,[pason_url] = a.pason_url
        ,[well_type] = a.well_type
        from [DrillingAnalysis].[Stage].[Well_Header] a
        left join DrillingAnalysis.DBO.Well_Header b
        on a.[pason_well_number] = b.[pason_well_number] 
        where a.Status = 'Active'


        """)
    
    cursor = cnxn.cursor()
    cursor.execute(stmt)
    cnxn.commit()
    
    #Bit Report
    stmt = ("""

        MERGE dbo.Pason_Bit_Data as TARGET
        USING   dbo.[vCleanBitDataloader] as SOURCE
        ON TARGET.[pason well number] = SOURCE.[pason well number]
        AND TARGET.[index] = SOURCE.[index]
        WHEN MATCHED AND TARGET.[index] = SOURCE.[index]
            THEN UPDATE SET
            TARGET.[Size] = SOURCE.[Size]
            ,TARGET.[mfr] = SOURCE.[mfr]
            ,TARGET.[Type] = SOURCE.[Type]
            ,TARGET.[IADC] = SOURCE.[IADC]
            ,TARGET.[Serial No] = SOURCE.[Serial No]
            ,TARGET.[Depth Out] = SOURCE.[Depth Out]
            ,TARGET.[Depth Drilled] = SOURCE.[Depth Drilled]
            ,TARGET.[Hours] = SOURCE.[Hours]
            ,TARGET.[Accum Hrs] = SOURCE.[Accum Hrs]
            ,TARGET.[ROP] = SOURCE.[ROP]
            ,TARGET.[Weight] = SOURCE.[Weight]
            ,TARGET.[RPM] = SOURCE.[RPM]
            ,TARGET.[Date Run] = SOURCE.[Date Run]
            ,TARGET.[Depth in Calc] = SOURCE.[Depth in Calc]
            ,TARGET.[pason well number] = SOURCE.[pason well number]
        WHEN NOT MATCHED BY TARGET
            THEN insert
                ([index]
            ,[no]
            ,[Size]
            ,[mfr]
            ,[Type]
            ,[IADC]
            ,[Serial No]
            ,[Depth Out]
            ,[Depth Drilled]
            ,[Hours]
            ,[Accum Hrs]
            ,[ROP]
            ,[Weight]
            ,[RPM]
            ,[Date Run]
            ,[Depth in Calc]
            ,[pason well number])
            VALUES (SOURCE.[index]
            ,SOURCE.[no]
            ,SOURCE.[Size]
            ,SOURCE.[mfr]
            ,SOURCE.[Type]
            ,SOURCE.[IADC]
            ,SOURCE.[Serial No]
            ,SOURCE.[Depth Out]
            ,SOURCE.[Depth Drilled]
            ,SOURCE.[Hours]
            ,SOURCE.[Accum Hrs]
            ,SOURCE.[ROP]
            ,SOURCE.[Weight]
            ,SOURCE.[RPM]
            ,SOURCE.[Date Run]
            ,SOURCE.[Depth in Calc]
            ,SOURCE.[pason well number]);

        
        """)

    cursor = cnxn.cursor()
    cursor.execute(stmt)
    cnxn.commit()





def main(): 
    scraper = make_scraper(headless=False)
    login_to_pason(scraper)
    well_numbers = get_active_well_numbers(scraper)
    
    pason_live_df=get_pason_live_df(scraper, well_numbers)
    well_header_df=get_well_header_df(scraper)
    bit_report_df=get_bit_report_df(scraper, well_numbers) 
    
    #insert & merge resulting datasets
    insert_SQL(pason_live_df,well_numbers,well_header_df,bit_report_df)
    mergeSQL()


if __name__ == '__main__':
    main()
