// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract SistemaSaude {
    //Controle de acesso
    address public owner;
    constructor() {
        owner = msg.sender; 
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Apenas o administrador pode realizar esta operacao");
        _;
    }

    //Structs
    struct Medico {
        uint crm;
        string nome;
        string especialidade;
    }

    struct Paciente {
        uint cpf;
        string nome;
        uint idade;
        string dataNascimento;
    }

    struct LocalAtendimento {
        uint idLocal;
        string endereco;
        string cidade;
        string estado;
    }

    struct Consulta {
        uint idConsulta;
        uint cpfPaciente;
        uint crmMedico;
        uint idLocal;
        string laudo;
        string medicamento;
        string data;
    }

    //Armazenamento
    mapping(uint => Medico) private medicos;
    mapping(uint => Paciente) private pacientes;
    mapping(uint => LocalAtendimento) private locais;
    mapping(uint => Consulta) private consultas;
    uint[] private idsConsultas;

    //Funções de inserções no sistema (médico, paciente, local e consulta)
    function cadastrarMedico(uint crm, string memory nome, string memory esp) public onlyOwner {
        require(crm != 0, "CRM invalido");
        require(medicos[crm].crm == 0, "CRM ja cadastrado");
        medicos[crm] = Medico(crm, nome, esp);
    }

    function cadastrarPaciente(uint cpf, string memory nome, uint idade, string memory nasc) public onlyOwner {
        require(cpf != 0, "CPF invalido");
        require(pacientes[cpf].cpf == 0, "CPF ja cadastrado");
        pacientes[cpf] = Paciente(cpf, nome, idade, nasc);
    }

    function cadastrarLocal(uint idLocal, string memory ender, string memory cid, string memory uf) public onlyOwner {
        require(idLocal != 0, "ID de local invalido");
        require(locais[idLocal].idLocal == 0, "ID do local ja cadastrado");
        locais[idLocal] = LocalAtendimento(idLocal, ender, cid, uf);
    }

    function registrarConsulta(
        uint idConsulta,
        uint cpf,
        uint crm,
        uint idLocal,
        string memory laudo,
        string memory medicamento,
        string memory dataConsulta
    ) public onlyOwner {

        require(idConsulta != 0, "ID da consulta invalido");
        require(consultas[idConsulta].idConsulta == 0, "ID da consulta ja cadastrado");

        require(pacientes[cpf].cpf != 0, "Paciente nao encontrado");
        require(medicos[crm].crm != 0, "Medico nao encontrado");
        require(locais[idLocal].idLocal != 0, "Local nao encontrado");

        consultas[idConsulta] = Consulta(
            idConsulta,
            cpf,
            crm,
            idLocal,
            laudo,
            medicamento,
            dataConsulta
        );

        idsConsultas.push(idConsulta);
    }

    //Funções de buscas no sistema (médico, paciente, local e consulta)
    function getMedico(uint crm) public view returns (
            uint _crm,
            string memory _nome,
            string memory _especialidade
        )
    {
        require(medicos[crm].crm != 0, "Medico nao encontrado");
        Medico memory m = medicos[crm];
        return (m.crm, m.nome, m.especialidade);
    }

    function getPaciente(uint cpf) public view returns (
            uint _cpf,
            string memory _nome,
            uint _idade,
            string memory _dataNascimento
        )
    {
        require(pacientes[cpf].cpf != 0, "Paciente nao encontrado");
        Paciente memory p = pacientes[cpf];
        return (p.cpf, p.nome, p.idade, p.dataNascimento);
    }

    function getLocal(uint idLocal) public view returns (
            uint _idLocal,
            string memory _endereco,
            string memory _cidade,
            string memory _estado
        )
    {
        require(locais[idLocal].idLocal != 0, "Local nao encontrado");
        LocalAtendimento memory l = locais[idLocal];
        return (l.idLocal, l.endereco, l.cidade, l.estado);
    }

    function getConsulta(uint idConsulta) public view returns (
            uint _idConsulta,
            uint _cpfPaciente,
            string memory _nomePaciente,
            uint _crmMedico,
            string memory _nomeMedico,
            uint _idLocal,
            string memory _cidadeLocal,
            string memory _laudo,
            string memory _medicamento,
            string memory _data
        )
    {
        require(consultas[idConsulta].idConsulta != 0, "Consulta nao encontrada");

        Consulta memory c = consultas[idConsulta];
        Paciente memory p = pacientes[c.cpfPaciente];
        Medico memory m = medicos[c.crmMedico];
        LocalAtendimento memory l = locais[c.idLocal];

        return (
            c.idConsulta,
            p.cpf,
            p.nome,
            m.crm,
            m.nome,
            l.idLocal,
            l.cidade,
            c.laudo,
            c.medicamento,
            c.data
        );
    }

    //Lista de todos os IDs das consultas
    function listarIdsConsultas() public view returns (uint[] memory) {
        require(idsConsultas.length > 0, "Nenhuma consulta cadastrada");
        return idsConsultas;
    }
}
