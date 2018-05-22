//
//  PDFViewController.swift
//  MesFactures
//
//  Created by Sébastien on 26/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var ui_navBarView: UIView!
    @IBOutlet weak var ui_scrollView: UIScrollView!
    @IBOutlet weak var ui_navBarImageView: UIImageView!
    
    //MARK: - Passsthrough variables
    var _ptManager: Manager?
    var _ptDocumentURL: URL?
    var _ptDocumentType: String?
    var _ptFontSize: CGFloat?
    
    //MARK: -  Variables
    var ui_jpgImageView: UIImageView!
    var _pdfView: PDFView!
    var _manager: Manager!
    var _documentURL: URL!
    var _documentType: String!
    
    
    //MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ui_scrollView.isHidden = true
        checkPassthroughData()
        configureUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func checkPassthroughData () {
        if let receivedManager = _ptManager,
            let receivedDocumentURL = _ptDocumentURL,
            let receivedDocumentType = _ptDocumentType {
                _manager = receivedManager
                _documentURL = receivedDocumentURL
                _documentType = receivedDocumentType
        }else {
            fatalError("At least one of the passtrhough data is missing")
        }
    }
    //TODO: - Configure the UI
    private func configureUI () {
        switch _documentType {
            case "PDF":
                //TODO: Create and configure the pdfView
                _pdfView = PDFView()
                // Set to false to use Auto Layout to dynamically calculate the size and position of the view
                _pdfView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(_pdfView)
                
                _pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                _pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                _pdfView.topAnchor.constraint(equalTo: ui_navBarView.bottomAnchor).isActive = true
                _pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                
                _pdfView.autoScales = true
                _pdfView.displayMode = .singlePageContinuous
            
                loadPDF()
            
            case "JPG":
                let scrollViewWidth = view.frame.size.width
                let scrollViewHeight = view.frame.size.height - ui_navBarImageView.frame.size.height
                
                //TODO: Create and configure the imageView
                if let imageToShow = _manager.getImageFromURL(url: _documentURL) {
                    ui_scrollView.isHidden = false
                    ui_scrollView.frame = CGRect(x: 0, y: 0, width: scrollViewWidth, height: scrollViewHeight)
                    ui_jpgImageView = UIImageView()
                    ui_jpgImageView.frame = CGRect(x: 0, y: 0, width: ui_scrollView.frame.size.width, height: ui_scrollView.frame.size.height)
                    ui_scrollView.addSubview(ui_jpgImageView)
                    ui_jpgImageView.isUserInteractionEnabled = true
                    ui_jpgImageView.image = imageToShow
                    ui_jpgImageView.contentMode = UIViewContentMode.center
                    ui_jpgImageView.frame = CGRect(x: 0, y: 0, width: imageToShow.size.width, height: imageToShow.size.height)
                    ui_scrollView.contentSize = imageToShow.size
                    
                    let scrollViewFrame = ui_scrollView.frame
                    let scaleWidth = scrollViewFrame.width / ui_scrollView.contentSize.width
                    let scaleHeight = scrollViewFrame.height / ui_scrollView.contentSize.height
                    let minScale = min(scaleWidth, scaleHeight)
                    
                    ui_scrollView.minimumZoomScale = minScale
                    ui_scrollView.maximumZoomScale = 1
                    ui_scrollView.zoomScale = minScale
                    
                    centerScrollViewContents()
                }else {
                    print("No image found at path :\(_documentURL)")
                }

            default:
                print("ERROR: No document type specified")
        }
    }
    
    private func centerScrollViewContents () {
        let boundSize = ui_scrollView.bounds.size
        var contentsFrame = ui_jpgImageView.frame
        
        if contentsFrame.size.width < boundSize.width {
            contentsFrame.origin.x = (boundSize.width - contentsFrame.size.width) / 2
        }else {
            contentsFrame.origin.x = 0
        }
        
        if contentsFrame.size.height < boundSize.height {
            contentsFrame.origin.y = (boundSize.height - contentsFrame.size.height) / 2
        }else {
            contentsFrame.origin.y = 0
        }
        ui_jpgImageView.frame = contentsFrame
    }
    
    private func getDocument () -> PDFDocument? {
        return PDFDocument(url: _documentURL)
    }
    
    private func loadPDF () {
        if let PDF = getDocument() {
            _pdfView.document = PDF
        }
    }
    
    //MARK: - Actions
    @IBAction func cancelViewController(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension PDFViewController: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return ui_jpgImageView
    }
}
