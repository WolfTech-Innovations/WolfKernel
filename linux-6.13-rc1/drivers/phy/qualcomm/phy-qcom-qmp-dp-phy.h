/* SPDX-License-Identifier: GPL-2.0 */
/*
 * Copyright (c) 2017, The Linux Foundation. All rights reserved.
 */

#ifndef QCOM_PHY_QMP_DP_PHY_H_
#define QCOM_PHY_QMP_DP_PHY_H_

/* QMP PHY - DP PHY registers */
#define QSERDES_DP_PHY_REVISION_ID0			0x000
#define QSERDES_DP_PHY_REVISION_ID1			0x004
#define QSERDES_DP_PHY_REVISION_ID2			0x008
#define QSERDES_DP_PHY_REVISION_ID3			0x00c
#define QSERDES_DP_PHY_CFG				0x010
#define QSERDES_DP_PHY_CFG_1				0x014
#define QSERDES_DP_PHY_PD_CTL				0x018
#define QSERDES_DP_PHY_MODE				0x01c
#define QSERDES_DP_PHY_AUX_CFG0				0x020
#define QSERDES_DP_PHY_AUX_CFG1				0x024
#define QSERDES_DP_PHY_AUX_CFG2				0x028
#define QSERDES_DP_PHY_AUX_CFG3				0x02c
#define QSERDES_DP_PHY_AUX_CFG4				0x030
#define QSERDES_DP_PHY_AUX_CFG5				0x034
#define QSERDES_DP_PHY_AUX_CFG6				0x038
#define QSERDES_DP_PHY_AUX_CFG7				0x03c
#define QSERDES_DP_PHY_AUX_CFG8				0x040
#define QSERDES_DP_PHY_AUX_CFG9				0x044

/* QSERDES COM_BIAS_EN_CLKBUFLR_EN bits */
# define QSERDES_V3_COM_BIAS_EN				0x0001
# define QSERDES_V3_COM_BIAS_EN_MUX			0x0002
# define QSERDES_V3_COM_CLKBUF_R_EN			0x0004
# define QSERDES_V3_COM_CLKBUF_L_EN			0x0008
# define QSERDES_V3_COM_EN_SYSCLK_TX_SEL		0x0010
# define QSERDES_V3_COM_CLKBUF_RX_DRIVE_L		0x0020
# define QSERDES_V3_COM_CLKBUF_RX_DRIVE_R		0x0040

/* QPHY_TX_TX_EMP_POST1_LVL bits */
# define DP_PHY_TXn_TX_EMP_POST1_LVL_MASK		0x001f
# define DP_PHY_TXn_TX_EMP_POST1_LVL_MUX_EN		0x0020

/* QPHY_TX_TX_DRV_LVL bits */
# define DP_PHY_TXn_TX_DRV_LVL_MASK			0x001f
# define DP_PHY_TXn_TX_DRV_LVL_MUX_EN			0x0020

/* QSERDES_DP_PHY_PD_CTL bits */
# define DP_PHY_PD_CTL_PWRDN				0x001
# define DP_PHY_PD_CTL_PSR_PWRDN			0x002
# define DP_PHY_PD_CTL_AUX_PWRDN			0x004
# define DP_PHY_PD_CTL_LANE_0_1_PWRDN			0x008
# define DP_PHY_PD_CTL_LANE_2_3_PWRDN			0x010
# define DP_PHY_PD_CTL_PLL_PWRDN			0x020
# define DP_PHY_PD_CTL_DP_CLAMP_EN			0x040

/* QPHY_DP_PHY_AUX_INTERRUPT_STATUS bits */
# define PHY_AUX_STOP_ERR_MASK				0x01
# define PHY_AUX_DEC_ERR_MASK				0x02
# define PHY_AUX_SYNC_ERR_MASK				0x04
# define PHY_AUX_ALIGN_ERR_MASK				0x08
# define PHY_AUX_REQ_ERR_MASK				0x10

#endif