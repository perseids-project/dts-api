Rails.application.routes.draw do
  get 'collections', to: 'collections#dts'
  get 'navigation', to: 'navigations#dts'
  get 'documents', to: 'documents#dts'

  root to: 'pages#dts'
end
