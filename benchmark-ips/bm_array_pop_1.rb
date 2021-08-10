Benchmark.ips do |x|
  x.report('pop(1)') do
    a = ['4768', '4964', '4266', '4872', '4231', '4017', '4565', '4793', '4298', '4135', '4639', '4780', '4237', '4548', '4655', '4153', '4654', '4922', '4563', '4042', '4329', '4699', '4352', '4127', '4544', '4906', '4814', '4948', '4977', '4830', '4405', '4642', '4666', '4402', '4679', '4465', '4401', '4155', '4767', '4510', '4747', '4993', '4508', '4697', '4758', '4133', '4348', '4200', '4442', '4970', '4452', '4041', '4103', '4567', '4937', '4047', '4933', '4121', '4860', '4659', '4221', '4312', '4583', '4473', '4973', '4262', '4630', '4123', '4139', '4289', '4147', '4222', '4050', '4019', '4454', '4253', '4552', '4947', '4725', '4457', '4929', '4021', '4502', '4307', '4576', '4124', '4586', '4610', '4027', '4572', '4926', '4753', '4185', '4382', '4394', '4923', '4186', '4254', '4012', '4417', '4556', '4349', '4550', '4330', '4938', '4985', '4778', '4716', '4924', '4045', '4358', '4189', '4591', '4213', '4851', '4825', '4260', '4198', '4342', '4824', '4333', '4244', '4752', '4994', '4488', '4532', '4082', '4595', '4098', '4436', '4540', '4267', '4407', '4998', '4751', '4535', '4861', '4819', '4419', '4031', '4029', '4453', '4698', '4965', '4450', '4668', '4036', '4300', '4519', '4281', '4981', '4818', '4939', '4378', '4140', '4841', '4249', '4290', '4388', '4878', '4884', '4235', '4515', '4638', '4410', '4054', '4383', '4238', '4870', '4295', '4804', '4308', '4614', '4105', '4053', '4446', '4757', '4971', '4637', '4831', '4193', '4912', '4000', '4187', '4606', '4566', '4169', '4641', '4749', '4729', '4928', '4601', '4949', '4210', '4313', '4647', '4495', '4460', '4621', '4605', '4694', '4317', '4226', '4263', '4016', '4997', '4940', '4715', '4907', '4620', '4934', '4996', '4955', '4688', '4304', '4220', '4882', '4772', '4536', '4815', '4693', '4469', '4276', '4409', '4071', '4224', '4020', '4629', '4865', '4813', '4366', '4622', '4129', '4533', '4634', '4564', '4087', '4386', '4161', '4265', '4711', '4009', '4376', '4781', '4837', '4112', '4915', '4592', '4658', '4025', '4987', '4291', '4477', '4503', '4437', '4111', '4707', '4879', '4611', '4549', '4078', '4044', '4853', '4835', '4463', '4577', '4008', '4233', '4741', '4384', '4225', '4024', '4726', '4743', '4160', '4180', '4722', '4609', '4114', '4834', '4742', '4662', '4984', '4299', '4060', '4498', '4755', '4320', '4874', '4528', '4216', '4852', '4951', '4958', '4283', '4239', '4476', '4644', '4143', '4104', '4455', '4126', '4950', '4663', '4013', '4931', '4850', '4242', '4130', '4623', '4871', '4014', '4854', '4293', '4512', '4166', '4740', '4735', '4150', '4651', '4172', '4836', '4530', '4664', '4429', '4511', '4558', '4676', '4085', '4074', '4580', '4794', '4379', '4310', '4817', '4966', '4848', '4202', '4336', '4608', '4351', '4396', '4652', '4033', '4188', '4431', '4916', '4259', '4607', '4816', '4810', '4627', '4527', '4560', '4728', '4589', '4274', '4809', '4790', '4398', '4414', '4516', '4581', '4919', '4665', '4331', '4978', '4543', '4877', '4974', '4284', '4004', '4177', '4466', '4116', '4217', '4901', '4372', '4137', '4806', '4264', '4497', '4294', '4787', '4212', '4215', '4115', '4782', '4739', '4821', '4125', '4505', '4230', '4399', '4395', '4079', '4867', '4381', '4706', '4695', '4404', '4691', '4075', '4353', '4301', '4876', '4731', '4523', '4246', '4529', '4412', '4784', '4449', '4229', '4616', '4158', '4002', '4318', '4377', '4205', '4911', '4777', '4792', '4271', '4763', '4141', '4287', '4890', '4279', '4829', '4646', '4840', '4089', '4880', '4067', '4918', '4059', '4109', '4164', '4863', '4883', '4909', '4361', '4174', '4960', '4302', '4003', '4236', '4846', '4034', '4324', '4513', '4765', '4596', '4900', '4007', '4603', '4474', '4439', '4805', '4015', '4496', '4953', '4363', '4551', '4459', '4063', '4983', '4881', '4365', '4604', '4587', '4798', '4005', '4163', '4421', '4471', '4826', '4144', '4635', '4600', '4913', '4640', '4247', '4766', '4779', '4280', '4391', '4891', '4636', '4546', '4683', '4181', '4081', '4862', '4458', '4037', '4321', '4786', '4717', '4628', '4154', '4326', '4032', '4873', '4151', '4905', '4270', '4156', '4733', '4980', '4866', '4325', '4055', '4467', '4480', '4286', '4191', '4762', '4322', '4574', '4022', '4056', '4770', '4451', '4448', '4845', '4341', '4433', '4245', '4684', '4671', '4093', '4920', '4272', '4745', '4799', '4761', '4250', '4578', '4347', '4499', '4526', '4369', '4162', '4537', '4434', '4893', '4120', '4962', '4667', '4525', '4091', '4462', '4182', '4738', '4935', '4173', '4490', '4571', '4424', '4894', '4051', '4214', '4823', '4096', '4206', '4598', '4943', '4701', '4649', '4807', '4107', '4435', '4456', '4083', '4612', '4721', '4472', '4146', '4925', '4340', '4789', '4277', '4375', '4211', '4427', '4547', '4690', '4613', '4727', '4006', '4203', '4430', '4223', '4039', '4932', '4296', '4108', '4278', '4832', '4422', '4917', '4470', '4183', '4887', '4076', '4485', '4597', '4443', '4257', '4991', '4944', '4196', '4672', '4397', '4097', '4119', '4077', '4773', '4602', '4538', '4479', '4968', '4159', '4539', '4956', '4710', '4812', '4902', '4569', '4954', '4385', '4128', '4936', '4416', '4148', '4632', '4759', '4117', '4896', '4392', '4864', '4316', '4132', '4319', '4969', '4175', '4484', '4903', '4910', '4350', '4332', '4952', '4176', '4594', '4709', '4509', '4178', '4167', '4545', '4857', '4617', '4501', '4859', '4207', '4275', '4687', '4049', '4579', '4046', '4921', '4113', '4898', '4681', '4052', '4415', '4064', '4184', '4895', '4744', '4685', '4084', '4305', '4899', '4559', '4208', '4057', '4507', '4258', '4355', '4086', '4373', '4323', '4541', '4297', '4483', '4889', '4531', '4327', '4441', '4914', '4303', '4677', '4445', '4802', '4343', '4585', '4338', '4524', '4590', '4624', '4288', '4704', '4134', '4043', '4720', '4058', '4328', '4095', '4026', '4423', '4657', '4118', '4633', '4487', '4822', '4904', '4255', '4001', '4387', '4500', '4190', '4686', '4995', '4661', '4783', '4992', '4165', '4065', '4927', '4306', '4856', '4292', '4420', '4963', '4468', '4240', '4724', '4432', '4447', '4518', '4028', '4670', '4339', '4771', '4018', '4489', '4110', '4708', '4945', '4136', '4492', '4930', '4090', '4734', '4886', '4542', '4227', '4486', '4491', '4713', '4986', '4068', '4048', '4975', '4570', '4842', '4475', '4131', '4555', '4428', '4776', '4101', '4273', '4811', '4345', '5000', '4653', '4256', '4209', '4769', '4946', '4561', '4080', '4461', '4820', '4311', '4959', '4750', '4795', '4748', '4368', '4506', '4335', '4346', '4568', '4675', '4692', '4774', '4413', '4370', '4723', '4521', '4885', '4678', '4897', '4066', '4674', '4106', '4626', '4389', '4204', '4839', '4023', '4712', '4145', '4035', '4357', '4756', '4648', '4972', '4157', '4406', '4615', '4061', '4219', '4791', '4660', '4073', '4356', '4072', '4599', '4359', '4094', '4673', '4696', '4796', '4282', '4714', '4522', '4736', '4775', '4760', '4400', '4847', '4228', '4803', '4908', '4732', '4645', '4122', '4218', '4478', '4941', '4892', '4364', '4403', '4152', '4444', '4360', '4354', '4241', '4494', '4367', '4808', '4261', '4088', '4573', '4554', '4248', '4371', '4393', '4268', '4201', '4038', '4788', '4593', '4040', '4801', '4582', '4309', '4976', '4374', '4869', '4380', '4514', '4243', '4362', '4849', '4680', '4888', '4764', '4618', '4838', '4828', '4643', '4010', '4827', '4957', '4099', '4875', '4843', '4737', '4102', '4979', '4011', '4504', '4440', '4746', '4557', '4426', '4553', '4656', '4868', '4689', '4988', '4703', '4967', '4069', '4619', '4334', '4669', '4785', '4464', '4562', '4961', '4625', '4754', '4797', '4481', '4705', '4199', '4337', '4062', '4138', '4702', '4534', '4168', '4418', '4092', '4682', '4520', '4030', '4171', '4650', '4858', '4411', '4999', '4252', '4197', '4170', '4942', '4631', '4990', '4179', '4285', '4700', '4482', '4575', '4800', '4070', '4251', '4344', '4982', '4719', '4390', '4149', '4100', '4194', '4269', '4855', '4314', '4718', '4232', '4730', '4438', '4588', '4195', '4192', '4493', '4517', '4833', '4234', '4989', '4315', '4844', '4142', '4408', '4584', '4425']
    a.pop(1)
  end

  x.compare!
end
