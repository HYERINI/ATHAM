from turtle import up
import pandas as pd
import requests
from bs4 import BeautifulSoup as bs
import time
from tqdm import tqdm
from selenium import webdriver

import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

cred = credentials.Certificate("./smu-clothes-b872b-firebase-adminsdk-npi8g-d28c4b9e5f.json")
firebase_admin.initialize_app(cred, {
  'projectId': 'smu-clothes-b872b',
})

db = firestore.client()



def uploadtofire(rankingData):
    doc_ref = db.collection(u'musinsa').document(u'ranking')
    print(rankingData)
    

    firstName = rankingData['의류명'][0]
    firstUrl = rankingData['링크'][0]
    firstPhoto = rankingData['좋아요'][0]

    secondName = rankingData['의류명'][1]
    secondUrl = rankingData['링크'][1]
    secondPhoto = rankingData['좋아요'][1]

    thirdName = rankingData['의류명'][2]
    thirdUrl = rankingData['링크'][2]
    thirdPhoto = rankingData['좋아요'][2]
    
    doc_ref.set({
        u'clothesName1': firstName,
        u'clothesUrl1': firstUrl,
        u'clothesPhoto1': firstPhoto,
        
        u'clothesName2': secondName,
        u'clothesUrl2': secondUrl,
        u'clothesPhoto2': secondPhoto,

        u'clothesName3': thirdName,
        u'clothesUrl3': thirdUrl,
        u'clothesPhoto3': thirdPhoto,
    })


maxTimes = 3
nowTimes = 0
def musinsa_rank():
    url = f"https://www.musinsa.com/ranking/best?period=now&age=ALL&mainCategory=&subCategory=&leafCategory=&price=&golf=false&kids=false&newProduct=false&exclusive=false&discount=false&soldOut=false&page=1&viewType=small&priceMin=&priceMax="
    response = requests.get(url)
    html = bs(response.text, 'lxml')
    musinsa_rank_df = rbnl(html)
    print("============================")
    print(musinsa_rank_df)
    return musinsa_rank_df

def rbnl(html):
    musinsa_rank_df = pd.DataFrame()
    
    #순위 뽑기
    rank_html = html.select('#goodsRankList > li > p')
    rank_no_list = []

    #for i in rank_html:
        
        #rank_no_list.append(i.string.strip())
        
    musinsa_rank_df['순위'] = [1,2,3]
    
    #브랜드 이름 뽑기
    brand_html = html.select('#goodsRankList > li > div.li_inner > div.article_info > p.item_title > a')
    brand_list = []
    
    nowTimes = 0
    for i in brand_html:
        if(nowTimes >= maxTimes):
            break
        nowTimes+=1
        brand_list.append(i.string)
    
    musinsa_rank_df['브랜드명']=brand_list
    
    #링크와 의류명 뽑기
    link_name_html = html.select('#goodsRankList > li > div.li_inner > div.article_info > p.list_info > a')
    link_list = []
    name_list = []
    
    nowTimes = 0
    for i in link_name_html:
        if(nowTimes >= maxTimes):
            break
        nowTimes+=1
        link_list.append(i['href'])
        name_list.append(i['title'])
        
    musinsa_rank_df['의류명']=name_list
    musinsa_rank_df['링크']=link_list
    
    #상세 페이지 크롤링
    musinsa_rank_df2 = specific_info(link_list)
    
    #데이터 프레임 옆으로 합치기
    musinsa_rank_df = pd.concat([musinsa_rank_df, musinsa_rank_df2], axis=1)
    
    return musinsa_rank_df

def specific_info(link_list):
    headers={'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.67 Safari/537.36'}
    
    musinsa_rank_df = pd.DataFrame()
    part_num_list=[]
    sex_list=[]
    view_list=[]
    sales_list=[]
    like_list=[]
    
    
    for link in tqdm(link_list):
#         print(link)
        response_1=requests.get(link,headers=headers)
        html_1=bs(response_1.text, 'lxml')
        
        #품번 리스트 생성
        part_num_html=html_1.select('#product_order_info > div.explan_product.product_info_section > ul > li:nth-child(1) > p.product_article_contents > strong')
        part_num=part_num_html[0].get_text().split('/')[-1].strip()
        part_num_list.append(part_num)
        
        #성별 리스트 생성
        sex_html=html_1.select("#product_order_info > div.explan_product.product_info_section > ul > li > p.product_article_contents > span.txt_gender")
        sex=sex_html[0].get_text().replace('\n',' ').strip()
        sex_list.append(sex)
        
        #셀레니움으로 원하는 데이터 가져오기
        driver = webdriver.Chrome('./chromedriver')
        driver.get(link)
        sel_html=driver.page_source
        html_2=bs(sel_html)
        
        #조회수 가져오기
        view_html=html_2.find_all("strong", {"id":"pageview_1m"})
        view=view_html[0].get_text()
        view_list.append(view)
        
        #누적 판매 가져오기
        sales_html=html_2.find_all("strong", {"id":"sales_1y_qty"})
        sales=sales_html[0].get_text()
        sales_list.append(sales)
        
        #좋아요 수 가져오기
        like_html=html_2.find_all("div", {"class": "product-img"})
        like = like_html[0].find("img")
        like = like.get("src")+"\n"
        #like=like_html[0].get_text()
        like = "https:" + like
        like_list.append(like)
        
        #드라이버 닫아주기
        driver.close()
        
        #시간 추가
        time.sleep(0.01)
        
    musinsa_rank_df['품번']=part_num_list
    musinsa_rank_df['성별']=sex_list
    musinsa_rank_df['조회수']=view_list
    musinsa_rank_df['누적판매량(1년)']=sales_list
    musinsa_rank_df['좋아요']=like_list
    print(musinsa_rank_df)
    return musinsa_rank_df

    
final_df=musinsa_rank()
uploadtofire(final_df)
