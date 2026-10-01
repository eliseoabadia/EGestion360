import json
from pathlib import Path
p=Path('artifacts/implementacion_2026/actividades.json')
w=json.loads(p.read_text(encoding='utf-8'))
w[7][3][2][0]='12 nov'
w[7][3][2][3]='ETL tres terminado'
w[9][3][5][4]='Autorizar o rechazar corte; sin firma, con diferencias de saldo no aprobadas o sin restauración probada, la decisión será NO GO.'
w[5][3][0][4]='Cargar maestros, saldos, presupuesto y movimientos; controlar lote y no duplicar pólizas. Conteos fuente iguales a aceptados más rechazados.'
p.write_text(json.dumps(w,ensure_ascii=False,indent=2),encoding='utf-8')