/* SPDX-License-Identifier: GPL-2.0 */
/* Copyright (C) 2019-2021, Intel Corporation. */

#ifndef _ICE_ESWITCH_H_
#define _ICE_ESWITCH_H_

#include <net/devlink.h>
#include "devlink/devlink_port.h"

#ifdef CONFIG_ICE_SWITCHDEV
void ice_eswitch_detach_vf(struct ice_pf *pf, struct ice_vf *vf);
void ice_eswitch_detach_sf(struct ice_pf *pf, struct ice_dynamic_port *sf);
int ice_eswitch_attach_vf(struct ice_pf *pf, struct ice_vf *vf);
int ice_eswitch_attach_sf(struct ice_pf *pf, struct ice_dynamic_port *sf);

int ice_eswitch_mode_get(struct devlink *devlink, u16 *mode);
int
ice_eswitch_mode_set(struct devlink *devlink, u16 mode,
		     struct netlink_ext_ack *extack);
bool ice_is_eswitch_mode_switchdev(struct ice_pf *pf);

void ice_eswitch_update_repr(unsigned long *repr_id, struct ice_vsi *vsi);

void ice_eswitch_stop_all_tx_queues(struct ice_pf *pf);

void ice_eswitch_set_target_vsi(struct sk_buff *skb,
				struct ice_tx_offload_params *off);
netdev_tx_t
ice_eswitch_port_start_xmit(struct sk_buff *skb, struct net_device *netdev);
struct net_device *ice_eswitch_get_target(struct ice_rx_ring *rx_ring,
					  union ice_32b_rx_flex_desc *rx_desc);

int ice_eswitch_cfg_vsi(struct ice_vsi *vsi, const u8 *mac);
void ice_eswitch_decfg_vsi(struct ice_vsi *vsi, const u8 *mac);
#else /* CONFIG_ICE_SWITCHDEV */
static inline void
ice_eswitch_detach_vf(struct ice_pf *pf, struct ice_vf *vf) { }

static inline void
ice_eswitch_detach_sf(struct ice_pf *pf, struct ice_dynamic_port *sf) { }

static inline int
ice_eswitch_attach_vf(struct ice_pf *pf, struct ice_vf *vf)
{
	return -EOPNOTSUPP;
}

static inline int
ice_eswitch_attach_sf(struct ice_pf *pf, struct ice_dynamic_port *sf)
{
	return -EOPNOTSUPP;
}

static inline void ice_eswitch_stop_all_tx_queues(struct ice_pf *pf) { }

static inline void
ice_eswitch_set_target_vsi(struct sk_buff *skb,
			   struct ice_tx_offload_params *off) { }

static inline void
ice_eswitch_update_repr(unsigned long *repr_id, struct ice_vsi *vsi) { }

static inline int ice_eswitch_mode_get(struct devlink *devlink, u16 *mode)
{
	return DEVLINK_ESWITCH_MODE_LEGACY;
}

static inline int
ice_eswitch_mode_set(struct devlink *devlink, u16 mode,
		     struct netlink_ext_ack *extack)
{
	return -EOPNOTSUPP;
}

static inline bool ice_is_eswitch_mode_switchdev(struct ice_pf *pf)
{
	return false;
}

static inline netdev_tx_t
ice_eswitch_port_start_xmit(struct sk_buff *skb, struct net_device *netdev)
{
	return NETDEV_TX_BUSY;
}

static inline struct net_device *
ice_eswitch_get_target(struct ice_rx_ring *rx_ring,
		       union ice_32b_rx_flex_desc *rx_desc)
{
	return rx_ring->netdev;
}

static inline int ice_eswitch_cfg_vsi(struct ice_vsi *vsi, const u8 *mac)
{
	return -EOPNOTSUPP;
}

static inline void ice_eswitch_decfg_vsi(struct ice_vsi *vsi, const u8 *mac) { }
#endif /* CONFIG_ICE_SWITCHDEV */
#endif /* _ICE_ESWITCH_H_ */