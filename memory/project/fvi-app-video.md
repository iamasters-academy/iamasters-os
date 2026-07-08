---
name: fvi-app-video
description: Proyecto FVI (Football Video Intelligence) — análisis de vídeo de fútbol CPU-only
metadata:
  type: project
---

# FVI — Football Video Intelligence

**Qué es:**
Sistema que extrae conocimiento táctico, técnico, físico y cognitivo de jugadores a partir de vídeo de fútbol, en hardware **CPU-only** (12 núcleos / 24 hilos, 64 GB RAM, **sin GPU**).

**Dos niveles:**
- **Tier 1** (disponible HOY): Analizador de reels (1 jugador, clips cortos). Detecta protagonista, etiqueta acciones on-ball, extrae pose/escaneo, produce informe.
- **Tier 2** (cuando haya partidos completos): ~125 métricas SOTA (tracking 22 jugadores, homografía, xG/xT/VAEP/OBV, pitch control, redes de pases, físicas, cognitivas). Batch nocturno CPU.

**Restricciones duras:**
- CPU-only: NO CUDA/TensorRT en runtime. Inferencia: ONNX Runtime + OpenVINO, cuantización INT8, modelos ligeros.
- Sin dependencia obligatoria de APIs externas. Operación autónoma local.
- Reproducible vía Docker.

**Honestidad analítica:**
- vs SkillCorner: 80-90% (ambos monocular)
- vs Second Spectrum/Hawk-Eye: 45-60% (necesitan hardware de estadio)
- Imposible sin GPU: Z del balón, biomecánica 3D SMPL fina, tracking sin pérdidas fuera de cámara
- Los reels tienen sesgo de selección: métricas NO son tasas representativas

**Estado 2026-07-08:**
- Plan mejoras creado (`INFORME_MEJORAS_PLAN.md`) con 12 cambios priorizados
- Pendiente implementar: reorganizar secciones, benchmarks comparativos, semáforos visuales 🟢🟡🔴
- Plan alineación con Informe Jugador IA creado

**Vive en:** VPS Contabo (`ssh polymaster-vps`), código por `scp` (NO `git pull`)

**Por qué importa:**
Producto core de futura agencia de representación (licencia FIFA en trámite). Fuente de verdad de métricas para Informe Jugador IA.

---
*Last updated: 2026-07-08*
