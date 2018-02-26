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
    
    //MARK: -  Variables
    var _pdfView: PDFView!
    var _documentURL: URL?
    
    //MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
        loadPDF()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func configureUI () {
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
    }
    
    private func getDocument () -> PDFDocument? {
        var document: PDFDocument? = nil
        if let documentURL = _documentURL {
            document = PDFDocument(url: documentURL)
        }
        return document
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
