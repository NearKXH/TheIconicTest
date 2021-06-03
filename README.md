# TheIconicTest
Base on MVVM with RxSwift by Cocoapods
## Project Directory
```
project
│
└───Interface  
│   └───Entension
│   └───Modules
│       └───ProductDetail
│           │   ProductDetailViewController
│           │   ProductDetailTableViewCell
│       └───Catalog
│           │   CatalogViewController
│           │   CatalogViewModel
│           │   CatalogProductVMModel
│           │   CatalogCollectionViewCell
│
└───BaseModules
│   └───Entension
│   └───RefreshStatus
│   └───ViewModel
│   └───UIBase
│   
└───Service
│   └───Base
│   └───Interface
│   └───Network
```

#### Directory Description
* Interface: Application layer Interface
   * Entension: application layer extension
   * Modules: interface modules
      * ProductDetail: product detail page
      * Catalog: catalog page
         * CatalogViewController: VC
         * CatalogViewModel: Catalog View Model
         * CatalogProductVMModel: The `Catalog Model` for application layer
         * CatalogCollectionViewCell: cell
* BaseModules: Base Module which can be transplant to other app as a framework
   * Entension: base class extension
   * RefreshStatus: refresh define and implement by VM
   * ViewModel: ViewModel Protocol
   * UIBase: UI base class
* Service: Responsable for service 
   * Interface:   Included `application layer service interface` and `service model `
   * Base:         The interface of base service
   * Network:   The implement of service

## Module Description
### Service
#### NetworkService
The base implement of network service, like get request. The request is wrapped follow `Request` protocol.
#### NetworkManager
The network manager of application layer. Service request include service request and image download. Interface include base interface and Rx interface.
#### ImageServiceManager
The Image Manager of download and cache. The key is made by sha of url. 
- memory cache from `ImageCache`, the count of cache is 100 as default
- local cache from disk
- request from service. After response, save in memory cache and disk
### Catalog Module
#### CatalogViewModel
2 pubilc property(`Input` and `Output`) and init method.
Init with `Input` which including one `Observable` of `Beginning Refresh Status`.
`Output` include two `Observable` which are `dataSource` and `Ending Refresh Status`.
Subscribe to `Input` internally and send the request `Single` after getting a `onNext` event.
Update the value (send `onNext` event) of `dataSource` and `Ending Refresh Status` `Observable` if the `Single` is `successed`. 
The model of `dataSource` is `CatalogProductVMModel` which is maped from `ProductModel`.
If the `Single` is `failure`, update `Ending Refresh Status`  by `.error(error)` and `dataSource` by `[]`. `dataSource` will be update only under `header` request. 
#### CatalogProductVMModel
The application layer model, including 2 `Observable`: `like` and `image`.
`like` is a `BehaviorRelay` which can be subscribed and updated. The model subscribe the `like` itself. Send request to service (simulation) when get a `onNext` event.
`image` is a getter property. A image download request will be send if the value of image `BehaviorRelay` is nil. 
#### CatalogViewController
Merge the `Ending Refresh Status Observable` and `Beginning Refresh Status Observable` into a `Observable`. And then, put this `Observable` to init a `CatalogProductVMModel`.
Subscribe the `dataSource` and `Ending Refresh Status`. Update collection view after getting a event of `dataSource`. Update `Header Refresh` and `Footer Refresh` after getting a event of `Ending Refresh Status`.
The `Header Refresh` is base on `UIRefreshControl`
### Footer Refresh
Footer Refresh inherit from `UIView`. It is add to scrollerView and set as a `AssociatedObject` of scrollerView.
Refresher include `begin BehaviorRelay` and `end BehaviorRelay`.
Refresher observe the `contentSize` and `panGestureRecognizer` of scrollerView. If the `status` of panGestureRecognizer is `End`  and the `contentOffset` meets the conditions of pull-up distance, then the UI layer change and the `begin BehaviorRelay` send an event.
Subscribe the `end BehaviorRelay`. UI layer update after getting an `ending` single.

