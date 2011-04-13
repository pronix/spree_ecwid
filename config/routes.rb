Rails.application.routes.draw do
  match "catalogue/product" => "fbstore#show", :as => "fbshow"
  match "catalogue" => "fbstore#catalogue", :as => "catalogue"
end
