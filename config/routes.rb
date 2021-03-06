Rails.application.routes.draw do
  match "fbcatalogue/product" => "fbstore#show", :as => "fbshow"
  match "fbcatalogue" => "fbstore#catalogue", :as => "fbcatalogue"
  match "vkcatalogue/product" => "vkstore#show", :as => "vkshow"
  match "vkcatalogue" => "vkstore#catalogue", :as => "vkcatalogue"
  match "fbcart" => "fbstore#cart", :as => "fbcart"
  match "vkcart" => "vkstore#cart", :as => "vkcart"
  match '/vkstore/pay' => 'vkstore#pay'
  match '/fbstore/api' => 'fbstore#api'
  match '/fbstore/auth' => 'fbstore#auth'
end
