class UsStocksController < ApplicationController
  before_action :authenticate_user!, only: []
  impressionist actions: [:show, :industry, :sector]

  def show
    @us_stock = UsStock.find_by_easy_symbol!(params[:id])
    all_industrys = UsStock.where(:industry => @us_stock.industry).select{ |x| x.static_data[2] != "0"  }   # 捞出所属行业列表, 并筛选出资料不为空的数据"".select"方法"
    @industrys_nonmember = all_industrys[0..35]            # 非会员时无排序
    @industrys = all_industrys      #全部所属行业列表
    @industrys_cash_order = all_industrys.sort{ |x,y| y.us_cash_order <=> x.us_cash_order }[0..22]       #所属行业现金量排序
    @industrys_operating_margin_order = all_industrys.sort{ |x,y| y.us_operating_margin_order <=> x.us_operating_margin_order }[0..22]     #毛利率排序
    @industrys_business_profitability_order = all_industrys.sort{ |x,y| y.us_business_profitability_order <=> x.us_business_profitability_order }[0..22]     #营业利益率排序
    @industrys_net_profit_margin_order = all_industrys.sort{ |x,y| y.us_net_profit_margin_order <=> x.us_net_profit_margin_order }[0..22]     #净利率排序
    @industrys_roe_order = all_industrys.sort{ |x,y| y.us_roe_order <=> x.us_roe_order }[0..22]       #股东权益报酬率 RoE 排序
    @industrys_debt_asset_order = all_industrys.sort{ |x,y| x.us_debt_asset_order <=> y.us_debt_asset_order }[0..22]       #负债占资本利率排序
    @industrys_dividend_rate_order = all_industrys.sort{ |x,y| y.us_dividend_rate_order <=> x.us_dividend_rate_order }[0..22]       #分红率排序


    # 笔记 note
    @note_new = UsNote.new
    if current_user
      @current_user_notes = @us_stock.us_notes.where( :user_id => current_user.id ).order("updated_at DESC")
    end
    @notes = @us_stock.us_notes.order("updated_at DESC").page(params[:notes]).per(20)

    # 股票现价\涨跌幅\市盈率\股息率 数列式
    @latest_price = @us_stock.us_stock_latest_price_and_PE

    #浏览量极速器
    impressionist(@us_stock)
  end


  # --- 行业对比页面, 在页面中显示该行业中, 指标排名靠前的股票排名 ---
  def industry
    @us_stocks = UsStock.all
    @industry = params[:order]                                                      # 参数来源之show 页面的传入
    all_industrys = UsStock.where(:industry => @industry).select{ |x| x.static_data[2] != "0"  }   # 捞出所属行业列表, 并筛选出资料不为空的数据"".select"方法"
    @industrys = all_industrys      #全部所属行业列表
    @industrys_cash_order = all_industrys.sort{ |x,y| y.us_cash_order <=> x.us_cash_order }[0..30]       #所属行业现金量排序
    @industrys_operating_margin_order = all_industrys.sort{ |x,y| y.us_operating_margin_order <=> x.us_operating_margin_order }[0..30]     #毛利率排序
    @industrys_business_profitability_order = all_industrys.sort{ |x,y| y.us_business_profitability_order <=> x.us_business_profitability_order }[0..30]     #营业利益率排序
    @industrys_net_profit_margin_order = all_industrys.sort{ |x,y| y.us_net_profit_margin_order <=> x.us_net_profit_margin_order }[0..30]     #净利率排序
    @industrys_roe_order = all_industrys.sort{ |x,y| y.us_roe_order <=> x.us_roe_order }[0..30]       #股东权益报酬率 RoE 排序
    @industrys_debt_asset_order = all_industrys.sort{ |x,y| x.us_debt_asset_order <=> y.us_debt_asset_order }[0..30]       #负债占资本利率排序
    @industrys_dividend_rate_order = all_industrys.sort{ |x,y| y.us_dividend_rate_order <=> x.us_dividend_rate_order }[0..30]       #分红率排序

    # 从"系统设置 - 行业"中提取行业列表
    @all_sectors = JSON.parse(Setting.first.us_sector)        # 所有行业信息
    # 从"系统设置 - 行业"中提取行业列表
    @all_industrys = JSON.parse(Setting.first.us_industry)        # 所有行业信息
  end

  # --- 领域对比页面, 在页面中显示该领域中, 指标排名靠前的股票排名 ---
  def sector
    @us_stocks = UsStock.all
    @sector = params[:order]                                                      # 参数来源之show 页面的传入
    all_sectors = UsStock.where(:sector => @sector).select{ |x| x.static_data[2] != "0"  }   # 捞出所属行业列表, 并筛选出资料不为空的数据"".select"方法"
    @sectors = all_sectors      #全部所属行业列表
    @sectors_cash_order = all_sectors.sort{ |x,y| y.us_cash_order <=> x.us_cash_order }[0..30]       #所属行业现金量排序
    @sectors_operating_margin_order = all_sectors.sort{ |x,y| y.us_operating_margin_order <=> x.us_operating_margin_order }[0..30]     #毛利率排序
    @sectors_business_profitability_order = all_sectors.sort{ |x,y| y.us_business_profitability_order <=> x.us_business_profitability_order }[0..30]     #营业利益率排序
    @sectors_net_profit_margin_order = all_sectors.sort{ |x,y| y.us_net_profit_margin_order <=> x.us_net_profit_margin_order }[0..30]     #净利率排序
    @sectors_roe_order = all_sectors.sort{ |x,y| y.us_roe_order <=> x.us_roe_order }[0..30]       #股东权益报酬率 RoE 排序
    @sectors_debt_asset_order = all_sectors.sort{ |x,y| x.us_debt_asset_order <=> y.us_debt_asset_order }[0..30]       #负债占资本利率排序
    @sectors_dividend_rate_order = all_sectors.sort{ |x,y| y.us_dividend_rate_order <=> x.us_dividend_rate_order }[0..30]       #分红率排序

    # 从"系统设置 - 行业"中提取行业列表
    @all_sectors = JSON.parse(Setting.first.us_sector)        # 所有行业信息
    # 从"系统设置 - 行业"中提取行业列表
    @all_industrys = JSON.parse(Setting.first.us_industry)        # 所有行业信息
  end


  # --- search 股票搜索 ---
  def search
    @query_string = params[:q].gsub(/\\|\'|\/|\?/, "") if params[:q].present?       # 拿到搜索框的 value 值
    if @query_string.present?
      @us_stock = UsStock.find_by_symbol!(@query_string.split(" - ")[0])
      redirect_to us_stock_path(@us_stock)
    end
  end

end
