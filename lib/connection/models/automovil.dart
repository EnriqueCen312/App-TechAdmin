class automovil{

    int id;
    int usuario_taller_id;
    String marca;
    String modelo;
    int anio;
    String color;
    String placa;
    
    automovil({
        required this.id,
        required this.usuario_taller_id,
        required this.marca,
        required this.modelo,
        required this.anio,
        required this.color,
        required this.placa,    
    });
    
    //convierte json a objeto automóvil
    factory automovil.fromJson(Map<String, dynamic> json){
        return automovil(
        id: json['id'],
        usuario_taller_id: json['usuario_taller_id'],
        marca: json['marca'],
        modelo: json['modelo'],
        anio: json['anio'],
        color: json['color'],
        placa: json['placa'],        
        );
    }
    
    //convierte objeto automovil a json
    Map<String, dynamic> toJson(){
        return{
        'id': id,
        'usuario_taller_id': usuario_taller_id,
        'marca': marca,
        'modelo': modelo,
        'anio': anio,
        'color': color,
        'placa': placa,
        };
    }

}
