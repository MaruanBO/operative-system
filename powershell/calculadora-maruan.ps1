Clear-Host
Write-Host "CALCULADORA"
Write-Host "Opcion 1: sumar"
Write-Host "Opcion 2: restart"
Write-Host "Opcion 3: factorial"
Write-Host "Opcion 4: salir"
Write-Host "__________________________"
$option = Read-Host "Elije una opción"
$result = 0

if ($option -eq 1 -or $option -eq 2 -or $option -eq 3 -or $option -eq 4) {
        
    if ($option -eq 1){
            [int]$num1 = Read-Host "Valor 1"
            [int]$num2 = Read-Host "Valor 2"
            $result = $num1 + $num2
            Write-Host "La suma es $result" 
     }

     if ($option -eq 2){
        [int]$num1 = Read-Host "Valor 1"
        [int]$num2 = Read-Host "Valor 2"
        $result = $num1 - $num2
        Write-Host "La resta es $result" 
      }

      if ($option -eq 3){
        [int]$num1 = Read-Host "Valor 1"          
            $cont = 1
            for ($i = 1; $i -le $num1; $i++){
                $cont = $cont * $i;
            }
        Write-Host "Su factorial es $cont"
      }

      if($option -eq 4){
        Write-Host "Saliendo del programa..."
        exit
      }

    } else {
        Write-Host "Opción invalida"
}
