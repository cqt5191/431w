class ProductController < ApplicationController

  include SessionsHelper

  def index

  	@einfo = EInfo.where(:id => params[:id]).limit(1)
  	@einfo.each { |ei|
  		@einfo = ei
  	}

  	@cat_array = Array.new
  	make_cat_array(@einfo.e_category_id)

  end

  def delete
    if !logged_in?
      flash[:danger] = 'Not logged in!'

      redirect_to product_url(:id => params[:id])
      return
    end
    
    params[:quantity].to_i.times do |i|
      Order.create(:bank => 'Nat Penn', credit: '999xxxxxxxxxxxxx', address: '1234 High Hill Rd', item_id: params[:id], registered_user_id: current_user.id)
    end

    item = Item.where(:e_info_id => params[:id]).limit(1)
    item.each { |ei|
      item = ei
    }

    if (item.quantity.to_i - params[:quantity].to_i) > 1
      item.update(:e_info_id => params[:id], :quantity => (item.quantity.to_i - params[:quantity].to_i).to_s)
    else
      item.update(:e_info_id => params[:id], :quantity => 0.to_s)
      redirect_to shop_path
      return
    end

    redirect_to product_url(:id => params[:id])
    return
  end

  def bid
    if !logged_in?
      flash[:danger] = 'Not logged in!'

      redirect_to product_url(:id => params[:id])
      return
    end

    bi = BidInfo.where(:item_id => params[:hid]).limit(1)
    bi.each { |ei|
      bi = ei
    }

    ai = AuctionProcess.where(:bid_info_id => bi.id).limit(1)
    ai.each { |ei|
      ai = ei
    }

    if params[:bid].to_i > ai.bid_price.to_i
      ai.update(bid_price: params[:bid], bid_info_id: bi.id)
    else
      flash[:danger] = 'Bid is not greater than current going price!'
    end

    redirect_to product_url(:id => params[:id])
    return
  end

  def make_cat_array(cat1)
  	ECategory.where(:id => cat1).limit(1).each do |cat|
  		if cat.parent_cat_id != 0
  			@cat_array.push(cat.name)
  			make_cat_array(cat.parent_cat_id)
  		else
  			break
  		end
  	end
  end

end
