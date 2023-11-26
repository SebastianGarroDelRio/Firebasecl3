//
//  ViewController.swift
//  CL3-ReyesRenzo
//
//  Created by DAMII on 20/11/23.
//

import UIKit
import Alamofire
import Kingfisher
import Toaster

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var pos = -1
    @IBOutlet weak var cvLibro: UICollectionView!
    
    @IBOutlet weak var txtLibro: UITextField!
    
    var listaLibro:ApiResponse = ApiResponse(error: "", total: "", page: "", books: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cvLibro.dataSource=self
        cvLibro.delegate=self
        cargarLibros()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listaLibro.books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = collectionView.dequeueReusableCell(withReuseIdentifier: "row",for:indexPath) as! ItemLibroCollectionViewCell
        row.lblTitulo.text = listaLibro.books[indexPath.row].title
        let url = URL(string: listaLibro.books[indexPath.row].image)
        row.imgLibro.kf.setImage(with: url)
        return row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (collectionView.frame.width - 20) / 2
            return CGSize(width: width, height: 300)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pos=indexPath.row
        performSegue(withIdentifier: "detalle", sender: nil)
    }
    
    
    //metodo prepare para que pueda la flecha mandar datos a la otra pantalla
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detalle" {
            let row = segue.destination as! DetalleLibroViewController
            
            // Verificar si pos es un índice válido para listaLibro.books
            if pos >= 0 && pos < listaLibro.books.count {
                row.bean = listaLibro.books[pos]
            } else {
                // Manejar el caso en el que pos no es un índice válido
                print("Índice pos fuera de rango")
            }
        }
    }

    func cargarLibros() {
        AF.request("https://api.itbook.store/1.0/search/mongodb")
            .responseDecodable(of: ApiResponse.self){ data in
                //validar data
                guard let info = data.value else { return }
                self.listaLibro = info
                self.cvLibro.reloadData()
            }
    }
    
    @IBAction func btnBuscar(_ sender: UIButton) {
        let nombres = txtLibro.text ?? ""
        
        AF.request("https://api.itbook.store/1.0/search/" + nombres)
            .responseDecodable(of: ApiResponse.self){ data in
                //validar data
                guard let info = data.value else { return }
                self.listaLibro = info
                self.cvLibro.reloadData()
            }
        
        if listaLibro.books.count == 0 {
            Toast(text: "No se encontraron resultados").show()
        }
    }
    
    @IBAction func btnLibro(_ sender: UIButton) {
        performSegue(withIdentifier: "isb", sender: nil)
    }
}

