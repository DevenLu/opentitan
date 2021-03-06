// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class alert_handler_env_cfg extends cip_base_env_cfg #(.RAL_T(alert_handler_reg_block));

  // ext component cfgs
  esc_en_vif           esc_en_vif;
  entropy_vif          entropy_vif;
  rand alert_agent_cfg alert_host_cfg[];
  rand alert_agent_cfg esc_device_cfg[];

  `uvm_object_utils_begin(alert_handler_env_cfg)
    `uvm_field_array_object(alert_host_cfg, UVM_DEFAULT)
    `uvm_field_array_object(esc_device_cfg, UVM_DEFAULT)
  `uvm_object_utils_end

  `uvm_object_new

  virtual function void initialize_csr_addr_map_size();
    this.csr_addr_map_size = ALERT_HANDLER_ADDR_MAP_SIZE;
  endfunction : initialize_csr_addr_map_size

  virtual function void initialize(bit [TL_AW-1:0] csr_base_addr = '1);
    super.initialize(csr_base_addr);

    // set num_interrupts & num_alerts
    begin
      uvm_reg rg = ral.get_reg_by_name("intr_state");
      if (rg != null) begin
        num_interrupts = ral.intr_state.get_n_used_bits();
      end
    end

    alert_host_cfg = new[alert_pkg::NAlerts];
    esc_device_cfg = new[alert_pkg::N_ESC_SEV];
    foreach (alert_host_cfg[i]) begin
      alert_host_cfg[i] = alert_agent_cfg::type_id::create($sformatf("alert_host_cfg[%0d]", i));
      alert_host_cfg[i].if_mode = dv_utils_pkg::Host;
    end
    foreach (esc_device_cfg[i]) begin
      esc_device_cfg[i] = alert_agent_cfg::type_id::create($sformatf("esc_device_cfg[%0d]", i));
      esc_device_cfg[i].if_mode  = dv_utils_pkg::Device;
      esc_device_cfg[i].is_alert = 0;
    end
  endfunction

endclass
