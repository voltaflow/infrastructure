# Monitoreo de Infraestructura

Este directorio contiene configuraciones para el monitoreo de la infraestructura.

## Configuración de NewRelic

Para el dashboard de NewRelic optimizado para visualización móvil, enfocado en monitoreo de:
- Servidor Ubuntu 24.04 on-premise
- PostgreSQL
- Consumo de energía

La configuración se encuentra implementada como código IaC con Terraform en:
```
/terraform/modules/monitoring/newrelic/
```

## Instrucciones de Despliegue

Para desplegar el dashboard:

1. Configure las variables de entorno para NewRelic:
```bash
export NEWRELIC_API_KEY="NRAK-..."
export NEWRELIC_ADMIN_API_KEY="NRAK-..."
export NEWRELIC_REGION="US"  # o "EU"
```

2. Navegue al directorio de entorno:
```bash
cd terraform/environments/prod
```

3. Copie y configure el archivo de variables:
```bash
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con el ID de cuenta correcto
```

4. Inicialice, planifique y aplique la configuración:
```bash
terraform init
terraform plan
terraform apply
```

5. Una vez desplegado, acceda al dashboard desde la aplicación móvil de NewRelic.